const std = @import("std");
const builtin = @import("builtin");
const jok = @import("jok");
const j2d = jok.j2d;
const geom = j2d.geom;
const zgui = jok.vendor.zgui;
const log = std.log.scoped(.shadersketch);

pub const jok_window_title: [:0]const u8 = "shadersketch";
pub const jok_window_resizable = true;
pub const jok_enable_physfs = false;
pub const jok_exit_on_recv_esc = false;
pub const jok_exit_on_recv_quit = false;

var always_on_top = false;
var ask_quit = false;
var batchpool: j2d.BatchPool(64, false) = undefined;

pub fn init(ctx: jok.Context) !void {
    zgui.styleColorsClassic(zgui.getStyle());
    try initShaderSource(ctx);
    batchpool = try @TypeOf(batchpool).init(ctx);
}

pub fn event(ctx: jok.Context, e: jok.Event) !void {
    _ = ctx;
    if (e == .quit) ask_quit = true;
}

pub fn update(ctx: jok.Context) !void {
    try checkAndLoadShader(ctx);
}

pub fn draw(ctx: jok.Context) !void {
    const vp = zgui.getMainViewport();
    zgui.setNextWindowPos(.{ .cond = .always, .pivot_x = 1.0, .x = vp.size[0], .y = 0 });
    if (zgui.begin("Menu", .{ .flags = .{
        .always_auto_resize = true,
        .no_title_bar = true,
    } })) {
        if (zgui.checkbox("Keep on top", .{ .v = &always_on_top })) {
            try ctx.window().setAlwaysOnTop(always_on_top);
        }
    }
    zgui.end();

    if (ask_quit) {
        ask_quit = false;
        zgui.openPopup("Quit?", .{});
    }

    zgui.setNextWindowPos(.{ .cond = .always, .pivot_x = 0.5, .pivot_y = 0.5, .x = vp.size[0] / 2, .y = vp.size[1] / 2 });
    if (zgui.beginPopupModal("Quit?", .{ .flags = .{ .no_resize = true } })) {
        if (zgui.button("YES", .{})) ctx.kill();
        zgui.sameLine(.{ .spacing = 10 });
        if (zgui.button("NO", .{})) zgui.closeCurrentPopup();
        zgui.endPopup();
    }

    const csz = ctx.getCanvasSize();
    if (shader) |s| {
        const mouse = jok.io.getMouseState(ctx);
        shader_param = .{
            .resolution = csz.toPoint(),
            .cursor = mouse.pos,
            .time = ctx.seconds(),
        };
        try s.setUniform(0, shader_param);
    }
    var b = try batchpool.new(.{ .shader = shader orelse null });
    defer b.submit();
    try b.rectFilled(csz.toRect(.origin), .rgb(30, 30, 40), .{});
}

pub fn quit(ctx: jok.Context) void {
    _ = ctx;
    batchpool.deinit();
}

//////////////////////////////////// Shader Management
const shader_template =
    \\cbuffer Context : register(b0, space3) {
    \\    float2 resolution;
    \\    float2 cursor;
    \\    float time;
    \\};
    \\
    \\Texture2D u_texture : register(t0, space2);
    \\SamplerState u_sampler : register(s0, space2);
    \\
    \\struct PSInput {
    \\    float4 v_pos: SV_POSITION;
    \\    float4 v_color : COLOR0;
    \\    float2 v_uv : TEXCOORD0;
    \\};
    \\
    \\struct PSOutput {
    \\    float4 o_color : SV_Target;
    \\};
    \\
    \\PSOutput main(PSInput input) {
    \\    PSOutput output;
    \\    float2 uv = input.v_pos.xy / resolution;
    \\    uv += cursor / resolution / 4;
    \\    float clr = 0;
    \\    clr += sin(uv.x * cos(time / 15) * 80) + cos(uv.y * cos(time / 15) * 10);
    \\    clr += sin(uv.y * sin(time / 10) * 40) + cos(uv.x * sin(time / 25) * 40);
    \\    clr += sin(uv.x * sin(time / 5) * 10) + sin(uv.y * sin(time / 35) * 80);
    \\    clr *= sin(time / 10) * 0.5;
    \\    output.o_color = float4(clr, clr * 0.5, sin(clr + time / 3) * 0.75, 1);
    \\    return output;
    \\}
    \\
;

const ShaderParam = extern struct {
    resolution: geom.Point,
    cursor: geom.Point,
    time: f32,
    padding: [3]f32 = undefined,
};

var shader: ?jok.PixelShader = null;
const shader_compiler = switch (builtin.os.tag) {
    .windows => "bin/SDL3_shadercross-3.0.0-windows-mingw-x64/bin/shadercross.exe",
    .linux => "bin/SDL3_shadercross-3.0.0-linux-x64/bin/shadercross",
    .macos => "bin/SDL3_shadercross-3.0.0-darwin-arm64-x64/bin/shadercross",
    else => unreachable,
};
const shader_source = "shader.frag.hlsl";
const shader_compiled = switch (builtin.os.tag) {
    .windows => "compiled.dxil",
    .linux => "compiled.spv",
    .macos => "compiled.msl",
    else => unreachable,
};
var shader_source_timestamp: i64 = 0;
var shader_check_timestamp: i64 = 0;
var shader_param: ShaderParam = undefined;

fn initShaderSource(ctx: jok.Context) !void {
    _ = std.Io.Dir.cwd().statFile(ctx.io(), shader_source, .{}) catch |e| {
        log.err("Access shader source failed: {s}", .{@errorName(e)});
        log.info("Try to create new source file {s} in working directory", .{shader_source});

        const file = try std.Io.Dir.cwd().createFile(ctx.io(), shader_source, .{ .truncate = true, .exclusive = true });
        defer file.close(ctx.io());
        var writer = file.writer(ctx.io(), &.{});
        try writer.interface.writeAll(shader_template);
    };
}

fn checkAndLoadShader(ctx: jok.Context) !void {
    const now = std.Io.Clock.now(.awake, ctx.io());
    if (now.toMilliseconds() - shader_check_timestamp < 1000) return;
    shader_check_timestamp = now.toMilliseconds();

    const stat_result = try std.Io.Dir.cwd().statFile(ctx.io(), shader_source, .{});
    if (stat_result.mtime.toMilliseconds() == shader_source_timestamp) return;
    shader_source_timestamp = stat_result.mtime.toMilliseconds();

    log.info("Detected newer shader source, attempt to compile shader...", .{});
    const result = try std.process.run(ctx.allocator(), ctx.io(), .{
        .argv = &.{
            shader_compiler,
            shader_source,
            "-o",
            shader_compiled,
        },
    });
    log.info("Done, exit code: {any}", .{result.term.exited});
    if (result.stderr.len > 0) {
        log.err("{s}", .{result.stderr});
        return;
    }

    shader = ctx.loadShader(shader_compiled, null, null) catch |e| {
        log.err("Load compiled shader failed: {s}", .{@errorName(e)});
        return;
    };
}

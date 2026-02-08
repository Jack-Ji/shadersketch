# shadersketch

A tiny Shadertoy-style playground for live fragment shader experiments, built with Zig + Jok.

## Features
- Live reload: edits to `shader.frag.hlsl` are detected and recompiled automatically.
- Simple uniform block with resolution, cursor, and time.
- Minimal UI with an always-on-top toggle.

## Quick start
```bash
zig build run
```
Run from the project root so the app can read/write `shader.frag.hlsl` in the working directory.

## Shader workflow
On startup, the app will create `shader.frag.hlsl` in the current working directory if it does not exist.
It then:
1. Watches for changes (about once per second).
2. Compiles with SDL3 shadercross.
3. Loads the compiled shader automatically.

The compiled output name depends on the OS:
- Windows: `compiled.dxil`
- Linux: `compiled.spv`
- macOS: `compiled.msl`

## Shader inputs
The fragment shader receives a constant buffer in `register(b0, space3)`:
```hlsl
cbuffer Context : register(b0, space3) {
    float2 resolution;
    float2 cursor;
    float time;
};
```
- `resolution`: canvas size in pixels
- `cursor`: mouse position in pixels
- `time`: seconds since start

## UI / Controls
- **Menu → Keep on top** toggles the window always-on-top state.
- Closing the window triggers a small quit confirmation dialog.

## Notes
- Shader compile errors are logged to stderr; the previous shader remains active.
- This is a minimal playground; expand the shader template in `src/main.zig` if you need more inputs.

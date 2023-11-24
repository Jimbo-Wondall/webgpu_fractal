struct VertexOutput {
    @builtin(position) clip_position: vec4<f32>,
    @location(0) vert_pos: vec3<f32>,
};

@vertex
fn vs_main(@builtin(vertex_index) index: u32) -> VertexOutput {
    var out: VertexOutput;
    let x = f32(1 - i32(index)) * 3.0;
    let y = f32(i32(index & 1u) * 2 - 1) * 3.0;
    out.clip_position = vec4<f32>(x, y, 0.0, 1.0);
    out.vert_pos = out.clip_position.xyz;
    return out;
}

struct Resolution {
    height: f32,
    width: f32,
    _padding1: f32,
    _padding2: f32,
};

@group(0) @binding(0)
var<uniform> iResolution: Resolution;

struct FractalParameters {
    scale: f32,
    offset_x: f32,
    offset_y: f32,
    max_iterations: u32,
};

@group(0) @binding(1)
var<uniform> params: FractalParameters;

@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
    // Pixel coordinates
    let frag = in.clip_position.xy; 
    // Current screen resolution as vec2
    let res = vec2<f32>(iResolution.height, iResolution.width); 
    // Current coordinates mapped to a system where 0,0 is center of screen
    // and y=1 is bottom edge and x is scaled to screen width
    let uv = (frag.xy * 2.0 - res.xy) / res.y; 

    //let scale: f32 = 0.1;
    //let offset_x: f32 = -1.3;
    //let offset_y: f32 = 0.0;
    //let max_iterations: u32 = 5000u;
    var c_re: f32 = uv.x * params.scale + params.offset_x;
    var c_im: f32 = uv.y * params.scale + params.offset_y;
    var z_re: f32 = 0.0;
    var z_im: f32 = 0.0;
    var i: u32 = 0u;

    for (; i < params.max_iterations; i = i + 1u) {
        var z_re2: f32 = z_re * z_re;
        var z_im2: f32 = z_im * z_im;
        if (z_re2 + z_im2 > 4.0) {
            break;
        }
        var new_re: f32 = z_re2 - z_im2 + c_re;
        var new_im: f32 = 2.0 * z_re * z_im + c_im;
        z_re = new_re;
        z_im = new_im;
    }

    var color: f32 = f32(i) / f32(params.max_iterations);
    return vec4<f32>(color, color, color, 1.0);
}

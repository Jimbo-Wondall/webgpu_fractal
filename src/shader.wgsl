[[block]]
struct Constants {
    width: u32;
    height: u32;
    scale: f32;
    offsetX: f32;
    offsetY: f32;
    maxIterations: u32;
};

[[group(0), binding(0)]]
var<uniform> constants: Constants;

[[stage(vertex)]]
fn vertex_main(
    [[builtin(vertex_index)]] vertexIndex: u32
) -> [[builtin(position)]] vec4<f32> {
    var x: f32 = f32(iRem(vertexIndex, constants.width));
    var y: f32 = f32(iDiv(vertexIndex, constants.width));
    x = (x / f32(constants.width - 1u)) * 2.0 - 1.0;
    y = (y / f32(constants.height - 1u)) * 2.0 - 1.0;
    return vec4<f32>(x, y, 0.0, 1.0);
}

[[stage(fragment)]]
fn fragment_main(
    [[builtin(position)]] position: vec4<f32>
) -> [[location(0)]] vec4<f32> {
    var c_re: f32 = position.x * constants.scale + constants.offsetX;
    var c_im: f32 = position.y * constants.scale + constants.offsetY;
    var z_re: f32 = 0.0;
    var z_im: f32 = 0.0;
    var i: u32 = 0u;

    for (; i < constants.maxIterations; i = i + 1u) {
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

    var color: f32 = f32(i) / f32(constants.maxIterations);
    return vec4<f32>(color, color, color, 1.0);
}

const Self = @This();

x: f64,
y: f64,
width: f64,
height: f64,

pub fn init(x: f64, y: f64, width: f64, height: f64) Self {
    return .{
        .x = x,
        .y = y,
        .width = width,
        .height = height,
    };
}

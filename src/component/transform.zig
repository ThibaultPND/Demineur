const eng = @import("../engine.zig");

pub const Transform = struct {
    const Self = @This();
    position: eng.Vec2,
    pub fn init(position: eng.Vec2) Self {
        return .{ .position = position };
    }
};

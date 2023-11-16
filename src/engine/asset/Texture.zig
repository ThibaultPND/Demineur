const sdl = @import("sdl2");

const Vec2 = @import("../vec2.zig").Vec2;

const Self = @This();

raw: *sdl.SDL_Texture,

pub fn fromRaw(raw: *sdl.SDL_Texture) Self {
    return .{
        .raw = raw,
    };
}

pub fn getSize(self: Self) Vec2 {
    var size: sdl.SDL_Point = undefined;
    _ = sdl.SDL_QueryTexture(self.raw, null, null, &size.x, &size.y);

    return .{ @floatFromInt(size.x), @floatFromInt(size.y) };
}

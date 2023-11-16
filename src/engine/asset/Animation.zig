const eng = @import("../../engine.zig");

const Self = @This();

pub const Infos = struct {
    texture_path: [:0]const u8,
    frame_size: eng.Vec2,
    start_frame: u32,
    end_frame: u32,
    delay: u32,
    loop: bool,
};

texture: eng.asset.Texture,

frame_size: eng.Vec2,
start_frame: u32,
end_frame: u32,
frame: u32 = 0,

delay: u32,
delay_value: u32 = 0,

loop: bool,

pub fn init(texture: eng.asset.Texture, frame_size: eng.Vec2, start_frame: u32, end_frame: u32, delay: u32, loop: bool) Self {
    return .{
        .texture = texture,
        .frame_size = frame_size,
        .start_frame = start_frame,
        .end_frame = end_frame,
        .delay = delay,
        .loop = loop,
    };
}

pub fn fromInfos(asset_manager: *eng.AssetManager, infos: Infos) !Self {
    return init(
        try asset_manager.loadImage(infos.texture_path),
        infos.frame_size,
        infos.start_frame,
        infos.end_frame,
        infos.delay,
        infos.loop,
    );
}

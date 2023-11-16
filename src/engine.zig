pub const asset = @import("engine/asset.zig");

pub const AssetManager = @import("engine/AssetManager.zig");
pub const Rect = @import("engine/Rect.zig");
pub const vec2 = @import("engine/vec2.zig");
pub const Vec2 = vec2.Vec2;
pub const vec3 = @import("engine/vec3.zig");
pub const Vec3 = vec3.Vec3;
pub const Window = @import("engine/Window.zig");

const sdl = @import("sdl2");

pub fn init() !void {
    if (sdl.SDL_Init(sdl.SDL_INIT_VIDEO) != 0) {
        return error.CouldNotInitSdl;
    }

    const sdl_image_flags = sdl.IMG_INIT_PNG;

    if (sdl.IMG_Init(sdl_image_flags) != sdl_image_flags) {
        return error.CouldNotInitSdlImage;
    }
}

pub fn deinit() void {
    sdl.IMG_Quit();
    sdl.SDL_Quit();
}

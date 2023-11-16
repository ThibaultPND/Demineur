const std = @import("std");

const sdl = @import("sdl2");

const eng = @import("../engine.zig");

const Self = @This();

fn JsonInfos(comptime Infos: type, comptime T: type) type {
    return struct {
        buffer: std.ArrayList(u8),
        parsed: std.json.Parsed(Infos),
        value: T,

        pub fn init(buffer: std.ArrayList(u8), parsed: std.json.Parsed(Infos), value: T) @This() {
            return .{
                .buffer = buffer,
                .parsed = parsed,
                .value = value,
            };
        }

        pub fn deinit(self: @This()) void {
            self.parsed.deinit();
            self.buffer.deinit();
        }
    };
}

allocator: std.mem.Allocator,
window: eng.Window,
textures: std.StringArrayHashMap(eng.asset.Texture),

animations_infos: std.StringArrayHashMap(JsonInfos(eng.asset.Animation.Infos, eng.asset.Animation)),

pub fn init(allocator: std.mem.Allocator, window: eng.Window) Self {
    const textures = std.StringArrayHashMap(eng.asset.Texture).init(allocator);
    const animations_infos = std.StringArrayHashMap(JsonInfos(eng.asset.Animation.Infos, eng.asset.Animation)).init(allocator);

    return .{
        .allocator = allocator,
        .window = window,
        .textures = textures,

        .animations_infos = animations_infos,
    };
}

pub fn deinit(self: *Self) void {
    var animations_infos_iter = self.animations_infos.iterator();

    while (animations_infos_iter.next()) |entry| {
        const animation_infos = entry.value_ptr;
        animation_infos.deinit();
    }

    self.animations_infos.deinit();

    var textures_iter = self.textures.iterator();

    while (textures_iter.next()) |entry| {
        const texture = entry.value_ptr.*;
        sdl.SDL_DestroyTexture(texture.raw);
    }

    self.textures.deinit();
}

pub fn loadImage(self: *Self, path: [:0]const u8) !eng.asset.Texture {
    if (self.textures.get(path)) |texture| {
        return texture;
    }

    const surface = sdl.IMG_Load(path) orelse {
        return error.CouldNotLoadImage;
    };

    defer sdl.SDL_FreeSurface(surface);

    const texture_raw = sdl.SDL_CreateTextureFromSurface(self.window.renderer, surface) orelse {
        return error.CouldNotCreateTexture;
    };

    const texture = eng.asset.Texture.fromRaw(texture_raw);

    try self.textures.put(path, texture);

    return texture;
}

pub fn loadAnimation(self: *Self, path: []const u8) !eng.asset.Animation {
    if (self.animations_infos.get(path)) |animation_infos| {
        return animation_infos.value;
    }

    var file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    var buffer = std.ArrayList(u8).init(self.allocator);
    errdefer buffer.deinit();

    try file.reader().readAllArrayList(&buffer, std.math.maxInt(usize));

    const parsed = try std.json.parseFromSlice(eng.asset.Animation.Infos, self.allocator, buffer.items, .{});
    errdefer parsed.deinit();

    try self.animations_infos.put(
        path,
        JsonInfos(eng.asset.Animation.Infos, eng.asset.Animation).init(
            buffer,
            parsed,
            try eng.asset.Animation.fromInfos(
                self,
                parsed.value,
            ),
        ),
    );

    return self.animations_infos.get(path).?.value;
}

const std = @import("std");
const mes_fonctions = @import("component.zig");
const eng = @import("engine.zig");
// const sdl = @import("sdl2");
const ecs = @import("ecs");
const comp = @import("component.zig");
const res = @import("ressource.zig");
const bundle = @import("bundle.zig");

const window_width = 1000;
const window_height = 1000;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    try eng.init();
    defer eng.deinit();

    res.window = try eng.Window.init(allocator, "Demineur", window_width, window_height);
    defer res.window.deinit();

    var registry = ecs.Registry.init(allocator);
    defer registry.deinit();

    res.asset_manager = eng.AssetManager.init(allocator, res.window);
    defer res.asset_manager.deinit();
    for (0..10) |i| {
        for (0..10) |j| {
            _ = bundle.tile.init(
                &registry,
                comp.Transform.init(.{
                    @floatFromInt(i * 100),
                    @floatFromInt(j * 100),
                }),
                comp.Sprite.init(
                    try res.asset_manager.loadImage("assets/img/hidden_tile.bmp"),
                    .{ 100, 100 },
                ),
            );
        }
    }
    try bundle.tile.placeBomb(&registry);
    bundle.tile.initTiles(&registry);

    while (res.window.open) {
        try res.window.update();
        try bundle.tile.clickSystem(&registry);
        res.window.clear();
        comp.Sprite.renderSystem(&registry);
        res.window.display();
    }
}

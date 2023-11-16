const ecs = @import("ecs");
const comp = @import("../component.zig");
const res = @import("../ressource.zig");
const std = @import("std");
const rngGenerator = std.rand.DefaultPrng;

pub const grid_size = 10;

pub fn init(registry: *ecs.Registry, transform: comp.Transform, sprite: comp.Sprite) ecs.Entity {
    const entity = registry.create();

    registry.add(entity, transform);
    registry.add(entity, sprite);

    registry.add(entity, comp.Tile{});
    return entity;
}

pub fn clickSystem(registry: *ecs.Registry) !void {
    if (res.window.isInputActiveOnce("MOUSE_LEFT") or res.window.isInputActive("MOUSE_RIGHT")) {
        const mouse_position = res.window.getMousePos();

        var view = registry.view(.{ comp.Transform, comp.Tile, comp.Sprite }, .{});
        var view_iter = view.entityIterator();

        while (view_iter.next()) |entity| {
            const tile = view.getConst(comp.Tile, entity);

            if (tile.state == .hidden or tile.state == .hidden_bomb) {
                const transform = view.getConst(comp.Transform, entity);
                var sprite = view.get(comp.Sprite, entity);

                var position = mouse_position;
                position[0] -= @mod(position[0], 100);
                position[1] -= @mod(position[1], 100);
                if (transform.position[0] == position[0] and transform.position[1] == position[1]) {
                    if (tile.state == .hidden_bomb) {
                        sprite.texture = try res.asset_manager.loadImage("assets/img/bomb_tile.bmp");
                    }
                }
            } // else do nothing
        }
    }
}

pub fn getTileState(registry: *ecs.Registry, x: f64, y: f64) comp.Tile.State {
    var view = registry.view(.{ comp.Tile, comp.Transform }, .{});
    var iter = view.entityIterator();

    while (iter.next()) |entity| {
        const tile = view.getConst(comp.Tile, entity);
        const transform = view.getConst(comp.Transform, entity);

        if (((transform.position[0] == @as(f64, x * 100)) and (transform.position[1] == @as(f64, y * 100)))) {
            return tile.state;
        }
    }
    return comp.Tile.State.hidden;
}

pub fn placeBomb(registry: *ecs.Registry) !void {
    var rnd = std.rand.Xoshiro256.init(@intCast(std.time.milliTimestamp()));
    var view = registry.view(.{ comp.Tile, comp.Transform }, .{});
    var view_iter = view.entityIterator();

    for (0..10) |_| {
        view_iter.reset();
        var rand_x: u64 = undefined;
        var rand_y: u64 = undefined;

        while (true) {
            rand_x = @mod(rnd.next(), 10);
            rand_y = @mod(rnd.next(), 10);
            if (getTileState(registry, @floatFromInt(rand_x), @floatFromInt(rand_y)) != comp.Tile.State.hidden_bomb) {
                break;
            }
        }
        while (view_iter.next()) |entity| {
            var tile = view.get(comp.Tile, entity);
            const transform = view.getConst(comp.Transform, entity);
            if (((transform.position[0] == @as(f64, @floatFromInt(rand_x * 100))) and
                (transform.position[1] == @as(f64, @floatFromInt(rand_y * 100)))))
            {
                std.debug.print("{},{} devient une bombe !\n", .{ rand_x, rand_y });
                tile.state = comp.Tile.State.hidden_bomb;
                break;
            }
        }
    }
}
fn getNearbyBomb(registry: *ecs.Registry, transform: comp.Transform) u4 {
    var nb_bomb: u4 = 0;

    const pos_x = transform.position[0];
    const pos_y = transform.position[1];

    const indices = [_]f64{ -1, 0, 1 };
    for (indices) |i| {
        for (indices) |j| {
            if (i - 1 == 0 and j - 1 == 0) {
                continue;
            }

            if (pos_x + i - 1 < 0 or pos_y + j - 1 < 0 or
                pos_x + i - 1 > grid_size - 1 or pos_y + j - 1 > grid_size - 1)
            {
                continue;
            }

            if (getTileState(registry, pos_x + i - 1, pos_y + j - 1) == .hidden_bomb) {
                nb_bomb += 1;
            }
        }
    }
    return nb_bomb;
}

pub fn initTiles(registry: *ecs.Registry) void {
    var view = registry.view(.{ comp.Transform, comp.Tile }, .{});
    var iter = view.entityIterator();

    while (iter.next()) |entity| {
        const transform = view.getConst(comp.Transform, entity);
        var tile = view.get(comp.Tile, entity);

        if (tile.state != .hidden_bomb) {
            tile.nearby_bomb = getNearbyBomb(registry, transform);
        }
    }
}

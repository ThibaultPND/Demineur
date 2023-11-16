const sdl = @import("sdl2");
const eng = @import("../engine.zig");
const ecs = @import("ecs");
const res = @import("../ressource.zig");
const comp = @import("../component.zig");

pub const Sprite = struct {
    const Self = @This();

    texture: eng.asset.Texture,
    size: eng.Vec2,

    pub fn init(texture: eng.asset.Texture, size: eng.Vec2) Self {
        return .{
            .texture = texture,
            .size = size,
        };
    }

    pub fn renderSystem(registry: *ecs.Registry) void {
        var view = registry.view(.{ comp.Transform, Self }, .{});
        var view_iter = view.entityIterator();

        while (view_iter.next()) |entity| {
            const transform = view.getConst(comp.Transform, entity);
            const sprite = view.getConst(Self, entity);

            res.window.draw(
                sprite.texture,
                null,
                eng.Rect.init(
                    transform.position[0],
                    transform.position[1],
                    sprite.size[0],
                    sprite.size[1],
                ),
            );
        }
    }
};

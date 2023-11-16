const std = @import("std");

const sdl = @import("sdl2");

const eng = @import("../engine.zig");

const Self = @This();

const Input = struct {
    once: bool = true,
    key: std.ArrayList(u8),

    pub fn init(allocator: std.mem.Allocator, key_slice: []const u8) !@This() {
        var key = std.ArrayList(u8).init(allocator);
        errdefer key.deinit();

        try key.appendSlice(key_slice);

        return .{ .key = key };
    }

    pub fn deinit(self: @This()) void {
        self.key.deinit();
    }
};

allocator: std.mem.Allocator,
window: *sdl.SDL_Window,
renderer: *sdl.SDL_Renderer,
inputs: std.ArrayList(Input),
open: bool = true,

pub fn init(allocator: std.mem.Allocator, title: [*:0]const u8, width: u32, height: u32) !Self {
    const window = sdl.SDL_CreateWindow(
        title,
        sdl.SDL_WINDOWPOS_CENTERED,
        sdl.SDL_WINDOWPOS_CENTERED,
        @intCast(width),
        @intCast(height),
        sdl.SDL_WINDOW_SHOWN,
    ) orelse return error.CouldNotCreateWindow;

    const renderer = sdl.SDL_CreateRenderer(
        window,
        -1,
        sdl.SDL_RENDERER_ACCELERATED,
    ) orelse return error.CouldNotCreateRenderer;

    const inputs = std.ArrayList(Input).init(allocator);
    errdefer inputs.deinit();

    return .{
        .allocator = allocator,
        .window = window,
        .renderer = renderer,
        .inputs = inputs,
    };
}

pub fn deinit(self: *Self) void {
    for (self.inputs.items) |input| {
        input.deinit();
    }

    self.inputs.deinit();

    sdl.SDL_DestroyWindow(self.window);
    sdl.SDL_DestroyRenderer(self.renderer);
}

pub fn getSize(self: Self) eng.Vec2 {
    var width: c_int = undefined;
    var height: c_int = undefined;

    sdl.SDL_GetWindowSize(self.window, &width, &height);

    return .{ @floatFromInt(width), @floatFromInt(height) };
}

pub fn getMousePos(self: Self) eng.Vec2 {
    _ = self;

    var x: c_int = undefined;
    var y: c_int = undefined;

    _ = sdl.SDL_GetMouseState(&x, &y);

    return .{ @floatFromInt(x), @floatFromInt(y) };
}

fn appendInput(self: *Self, input: []const u8) !void {
    if (self.isInputActive(input)) {
        return;
    }

    try self.inputs.append(try Input.init(self.allocator, input));
}

fn removeInput(self: *Self, key: []const u8) void {
    for (self.inputs.items, 0..self.inputs.items.len) |input, i| {
        if (!std.mem.eql(u8, input.key.items, key)) {
            continue;
        }

        _ = self.inputs.swapRemove(i);
        input.deinit();

        break;
    }
}

fn nativeMouseButtonToBytes(button: u32) ![]const u8 {
    return switch (button) {
        sdl.SDL_BUTTON_LEFT => "MOUSE_LEFT",
        sdl.SDL_BUTTON_MIDDLE => "MOUSE_MIDDLE",
        sdl.SDL_BUTTON_RIGHT => "MOUSE_RIGHT",
        else => error.InvalidButton,
    };
}

pub fn isInputActive(self: Self, query: []const u8) bool {
    return for (self.inputs.items) |input| {
        if (std.mem.eql(u8, input.key.items, query)) {
            break true;
        }
    } else false;
}

pub fn isInputActiveOnce(self: Self, query: []const u8) bool {
    return for (self.inputs.items) |input| {
        if (input.once and std.mem.eql(u8, input.key.items, query)) {
            break true;
        }
    } else false;
}

pub fn getInputStrength(self: Self, input: []const u8) i32 {
    return if (self.isInputActive(input)) 1 else 0;
}

pub fn update(self: *Self) !void {
    for (self.inputs.items) |*input| {
        if (!input.once) continue;
        input.once = false;
    }

    var event: sdl.SDL_Event = undefined;

    while (sdl.SDL_PollEvent(&event) != 0) {
        switch (event.type) {
            sdl.SDL_QUIT => self.open = false,
            sdl.SDL_MOUSEBUTTONDOWN => {
                const sdl_button = event.button.button;
                const button = try nativeMouseButtonToBytes(sdl_button);

                try self.appendInput(button);
            },
            sdl.SDL_MOUSEBUTTONUP => {
                const sdl_button = event.button.button;
                const button = try nativeMouseButtonToBytes(sdl_button);

                self.removeInput(button);
            },
            sdl.SDL_KEYDOWN => {
                const sdl_key = sdl.SDL_GetKeyName(event.key.keysym.sym);
                const span_sdl_key = std.mem.span(sdl_key);

                try self.appendInput(span_sdl_key);
            },
            sdl.SDL_KEYUP => {
                const sdl_key = sdl.SDL_GetKeyName(event.key.keysym.sym);
                const span_sdl_key = std.mem.span(sdl_key);

                self.removeInput(span_sdl_key);
            },
            else => {},
        }
    }
}

pub fn clear(self: Self) void {
    _ = sdl.SDL_RenderClear(self.renderer);
}

pub fn display(self: Self) void {
    sdl.SDL_RenderPresent(self.renderer);
}

pub fn draw(self: Self, texture: eng.asset.Texture, src_rect: ?eng.Rect, dest_rect: eng.Rect) void {
    var sdl_src_rect = if (src_rect) |rect| sdl.SDL_Rect{
        .x = @intFromFloat(rect.x),
        .y = @intFromFloat(rect.y),
        .w = @intFromFloat(rect.width),
        .h = @intFromFloat(rect.height),
    } else null;

    var sdl_dest_rect = sdl.SDL_Rect{
        .x = @intFromFloat(dest_rect.x),
        .y = @intFromFloat(dest_rect.y),
        .w = @intFromFloat(dest_rect.width),
        .h = @intFromFloat(dest_rect.height),
    };

    _ = sdl.SDL_RenderCopy(
        self.renderer,
        texture.raw,
        if (sdl_src_rect) |rect| &rect else null,
        &sdl_dest_rect,
    );
}

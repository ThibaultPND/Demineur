pub const Tile = struct {
    const Self = @This();
    pub const State = enum {
        hidden,
        bomb,
        hidden_bomb,
        flag,
        flag_bomb,
    };
    state: State = .hidden,
    nearby_bomb: u4 = 0,
};

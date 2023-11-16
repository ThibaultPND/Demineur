const std = @import("std");

const eng = @import("../engine.zig");

pub const Vec2 = @Vector(2, f64);
pub const zero = Vec2{ 0, 0 };

pub fn abs(vec: Vec2) Vec2 {
    return .{ @abs(vec[0]), @abs(vec[1]) };
}

pub fn mag(vec: Vec2) f64 {
    return std.math.sqrt(vec[0] * vec[0] + vec[1] * vec[1]);
}

pub fn forceMag(vec: Vec2, new_mag: f64) Vec2 {
    const scale_fac = new_mag / mag(vec);
    return vec * Vec2{ scale_fac, scale_fac };
}

pub fn maxMag(vec: Vec2, max: f64) Vec2 {
    if (mag(vec) <= max) {
        return vec;
    }

    return forceMag(vec, max);
}

pub fn norm(vec: Vec2) Vec2 {
    const vec_mag = mag(vec);

    if (vec_mag == 0) {
        return zero;
    }

    return vec / Vec2{ vec_mag, vec_mag };
}

pub fn lerp(fst: Vec2, sec: Vec2, t: f64) Vec2 {
    return .{
        std.math.lerp(fst[0], sec[0], t),
        std.math.lerp(fst[1], sec[1], t),
    };
}

pub fn intersect(fst_pos1: Vec2, fst_pos2: Vec2, sec_pos1: Vec2, sec_pos2: Vec2) bool {
    const den = (fst_pos1[0] - fst_pos2[0]) * (sec_pos1[1] - sec_pos2[1]) - (fst_pos1[1] - fst_pos2[1]) * (sec_pos1[0] - sec_pos2[0]);

    const t = ((fst_pos1[0] - sec_pos1[0]) * (sec_pos1[1] - sec_pos2[1]) - (fst_pos1[1] - sec_pos1[1]) * (sec_pos1[0] - sec_pos2[0])) / den;
    const u = ((fst_pos1[0] - sec_pos1[0]) * (fst_pos1[1] - fst_pos2[1]) - (fst_pos1[1] - sec_pos1[1]) * (fst_pos1[0] - fst_pos2[0])) / den;

    return (t >= 0 and t <= 1) and (u >= 0 and u <= 1);
}

pub fn intersectRect(seg_pos1: Vec2, seg_pos2: Vec2, rect: eng.Rect) bool {
    const top_left = .{ rect.x, rect.y };
    const top_right = .{ rect.x + rect.width, rect.y };

    const bottom_left = .{ rect.x, rect.y + rect.height };
    const bottom_right = .{ rect.x + rect.width, rect.y + rect.height };

    return intersect(seg_pos1, seg_pos2, top_left, top_right) or
        intersect(seg_pos1, seg_pos2, top_left, bottom_left) or
        intersect(seg_pos1, seg_pos2, bottom_right, top_right) or
        intersect(seg_pos1, seg_pos2, bottom_right, bottom_left);
}

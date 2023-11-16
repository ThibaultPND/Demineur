const std = @import("std");

pub const Vec3 = @Vector(3, f64);
pub const zero = Vec3{ 0, 0, 0 };

pub fn mag(vec: Vec3) f64 {
    return std.math.sqrt(vec[0] * vec[0] + vec[1] * vec[1] + vec[2] * vec[2]);
}

pub fn forceMag(vec: Vec3, new_mag: f64) Vec3 {
    const scale_fac = new_mag / mag(vec);
    return vec * Vec3{ scale_fac, scale_fac, scale_fac };
}

pub fn norm(vec: Vec3) Vec3 {
    const vec_mag = mag(vec);

    if (vec_mag == 0) {
        return zero();
    }

    return .{ vec[0] / vec_mag, vec[1] / vec_mag, vec[2] / vec_mag };
}

pub fn lerp(fst: Vec3, sec: Vec3, t: f64) Vec3 {
    return .{
        std.math.lerp(fst[0], sec[0], t),
        std.math.lerp(fst[1], sec[1], t),
        std.math.lerp(fst[2], sec[2], t),
    };
}

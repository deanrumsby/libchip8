const std = @import("std");
const testing = std.testing;

pub const Opcode = enum {
    op_00e0,
    op_1nnn,
    op_6xnn,
    op_7xnn,
    op_annn,
    op_dxyn,
};

pub const Instruction = struct {
    opcode: Opcode,
    value: u16,

    pub fn x(self: Instruction) u8 {
        return @intCast((self.value & 0x0f00) >> 8);
    }

    pub fn y(self: Instruction) u8 {
        return @intCast((self.value & 0x0f0) >> 4);
    }

    pub fn nn(self: Instruction) u8 {
        return @intCast(self.value & 0x00ff);
    }

    pub fn nnn(self: Instruction) u16 {
        return self.value & 0x0fff;
    }
};

test "7A72 correctly decomposes" {
    const inst: Instruction = .{
        .opcode = .op_7xnn,
        .value = 0x7a72,
    };

    try testing.expectEqual(0x0a, inst.x());
    try testing.expectEqual(0x07, inst.y());
    try testing.expectEqual(0x72, inst.nn());
    try testing.expectEqual(0xa72, inst.nnn());
}

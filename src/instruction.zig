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

    pub fn from_u16(word: u16) !Instruction {
        const first: u8 = @intCast((word & 0xf000) >> 12);

        return switch (first) {
            0x0 => .{ .opcode = .op_00e0, .value = word },
            0x1 => .{ .opcode = .op_1nnn, .value = word },
            0x6 => .{ .opcode = .op_6xnn, .value = word },
            0x7 => .{ .opcode = .op_7xnn, .value = word },
            0xa => .{ .opcode = .op_annn, .value = word },
            0xd => .{ .opcode = .op_dxyn, .value = word },
            else => error.InvalidInstruction,
        };
    }

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

test "0E00 correctly decodes" {
    const word: u16 = 0x00e0;
    const inst = try Instruction.from_u16(word);

    try testing.expectEqual(Opcode.op_00e0, inst.opcode);
    try testing.expectEqual(0x00e0, inst.value);
    try testing.expectEqual(0x00, inst.x());
    try testing.expectEqual(0x0e, inst.y());
    try testing.expectEqual(0xe0, inst.nn());
    try testing.expectEqual(0x00e0, inst.nnn());
}

test "1C4B correctly decodes" {
    const word: u16 = 0x1c4b;
    const inst = try Instruction.from_u16(word);

    try testing.expectEqual(Opcode.op_1nnn, inst.opcode);
    try testing.expectEqual(0x1c4b, inst.value);
    try testing.expectEqual(0x0c, inst.x());
    try testing.expectEqual(0x04, inst.y());
    try testing.expectEqual(0x4b, inst.nn());
    try testing.expectEqual(0x0c4b, inst.nnn());
}

test "602F correctly decodes" {
    const word: u16 = 0x602f;
    const inst = try Instruction.from_u16(word);

    try testing.expectEqual(Opcode.op_6xnn, inst.opcode);
    try testing.expectEqual(0x602f, inst.value);
    try testing.expectEqual(0x00, inst.x());
    try testing.expectEqual(0x02, inst.y());
    try testing.expectEqual(0x2f, inst.nn());
    try testing.expectEqual(0x002f, inst.nnn());
}

test "7A72 correctly decodes" {
    const word: u16 = 0x7a72;
    const inst = try Instruction.from_u16(word);

    try testing.expectEqual(Opcode.op_7xnn, inst.opcode);
    try testing.expectEqual(0x7a72, inst.value);
    try testing.expectEqual(0x0a, inst.x());
    try testing.expectEqual(0x07, inst.y());
    try testing.expectEqual(0x72, inst.nn());
    try testing.expectEqual(0x0a72, inst.nnn());
}

test "A123 correctly decodes" {
    const word: u16 = 0xa123;
    const inst = try Instruction.from_u16(word);

    try testing.expectEqual(Opcode.op_annn, inst.opcode);
    try testing.expectEqual(0xa123, inst.value);
    try testing.expectEqual(0x01, inst.x());
    try testing.expectEqual(0x02, inst.y());
    try testing.expectEqual(0x23, inst.nn());
    try testing.expectEqual(0x0123, inst.nnn());
}

test "DAB1 correctly decodes" {
    const word: u16 = 0xdab1;
    const inst = try Instruction.from_u16(word);

    try testing.expectEqual(Opcode.op_dxyn, inst.opcode);
    try testing.expectEqual(0xdab1, inst.value);
    try testing.expectEqual(0x0a, inst.x());
    try testing.expectEqual(0x0b, inst.y());
    try testing.expectEqual(0xb1, inst.nn());
    try testing.expectEqual(0x0ab1, inst.nnn());
}

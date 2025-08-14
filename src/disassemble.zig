const std = @import("std");
const testing = std.testing;
const Instruction = @import("instruction.zig").Instruction;

pub fn disassemble(allocator: std.mem.Allocator, source: []const u8) ![]u8 {
    if (source.len % 2 != 0) return error.InvalidLength;

    var list = std.ArrayList(u8).init(allocator);
    defer list.deinit();

    var i: usize = 0;
    while (i < source.len) : (i += 2) {
        var buf: [15]u8 = undefined;
        const opcode: u16 = (@as(u16, source[i]) << 8) | @as(u16, source[i + 1]);
        const inst = try Instruction.from_u16(opcode);

        const mnemonic = switch (inst.opcode) {
            .op_00e0 => try std.fmt.bufPrint(&buf, "CLS", .{}),
            .op_1nnn => try std.fmt.bufPrint(&buf, "JMP ${X:0>4}", .{inst.nnn()}),
            .op_6xnn => try std.fmt.bufPrint(&buf, "LD V{X}, #{d:0>2}", .{ inst.x(), inst.nn() }),
            .op_7xnn => try std.fmt.bufPrint(&buf, "ADD V{X}, #{d:0>2}", .{ inst.x(), inst.nn() }),
            .op_annn => try std.fmt.bufPrint(&buf, "LD I, ${X:0>4}", .{inst.nnn()}),
            .op_dxyn => try std.fmt.bufPrint(&buf, "DRW V{X}, V{X}, #{d:0>2}", .{ inst.x(), inst.y(), inst.n() }),
        };

        try list.appendSlice(mnemonic);
        try list.appendSlice("\n");
    }

    return list.toOwnedSlice();
}

test "disassembles 00E0 correctly" {
    const allocator = testing.allocator;

    const source = [_]u8{ 0x00, 0xE0 };
    const expected = "CLS\n";

    const actual = try disassemble(allocator, &source);
    defer allocator.free(actual);

    try testing.expectEqualStrings(expected, actual);
}

test "disassemble 1543 correctly" {
    const allocator = testing.allocator;

    const source = [_]u8{ 0x15, 0x43 };
    const expected = "JMP $0543\n";

    const actual = try disassemble(allocator, &source);
    defer allocator.free(actual);

    try testing.expectEqualStrings(expected, actual);
}

test "disassemble 6A2B correctly" {
    const allocator = testing.allocator;

    const source = [_]u8{ 0x6A, 0x2B };
    const expected = "LD VA, #43\n";

    const actual = try disassemble(allocator, &source);
    defer allocator.free(actual);

    try testing.expectEqualStrings(expected, actual);
}

test "disassemble 7102 correctly" {
    const allocator = testing.allocator;

    const source = [_]u8{ 0x71, 0x02 };
    const expected = "ADD V1, #02\n";

    const actual = try disassemble(allocator, &source);
    defer allocator.free(actual);

    try testing.expectEqualStrings(expected, actual);
}

test "disassemble A5D1 correctly" {
    const allocator = testing.allocator;

    const source = [_]u8{ 0xa5, 0xd1 };
    const expected = "LD I, $05D1\n";

    const actual = try disassemble(allocator, &source);
    defer allocator.free(actual);

    try testing.expectEqualStrings(expected, actual);
}

test "disassemble D75A correctly" {
    const allocator = testing.allocator;

    const source = [_]u8{ 0xd7, 0x5a };
    const expected = "DRW V7, V5, #10\n";

    const actual = try disassemble(allocator, &source);
    defer allocator.free(actual);

    try testing.expectEqualStrings(expected, actual);
}

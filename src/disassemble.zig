const std = @import("std");
const testing = std.testing;

pub fn disassemble(allocator: std.mem.Allocator, source: []const u8) ![]u8 {
    if (source.len % 2 != 0) return error.InvalidLength;

    var list = std.ArrayList(u8).init(allocator);
    defer list.deinit();

    var i: usize = 0;
    while (i < source.len) : (i += 2) {
        const opcode: u16 = (@as(u16, source[i]) << 8) | @as(u16, source[i + 1]);

        const mnemonic = switch (opcode) {
            0x00E0 => "CLS",
            else => "UNKNOWN",
        };

        try list.appendSlice(mnemonic);
        try list.appendSlice("\n");
    }

    return list.toOwnedSlice();
}

test "disassemble 00E0 to CLS" {
    const allocator = testing.allocator;

    const source = [_]u8{ 0x00, 0xE0 };
    const expected = "CLS\n";

    const actual = try disassemble(allocator, &source);
    defer allocator.free(actual);

    try testing.expectEqualStrings(expected, actual);
}

const std = @import("std");
const testing = std.testing;

extern fn print(i32) void;

pub export fn add(a: i32, b: i32) void {
    print(a + b);
}

test "basic add functionality" {
    try testing.expect(add(3, 7) == 10);
}

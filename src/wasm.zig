const std = @import("std");

const allocator = std.heap.wasm_allocator;

pub export fn malloc(size: usize) usize {
    if (size == 0) return 0;
    const mem = allocator.alloc(u8, size) catch return 0;
    return @intFromPtr(mem.ptr);
}

pub export fn free(ptr: usize, len: usize) void {
    if (ptr == 0 or len == 0) return;
    const slice_ptr: [*]u8 = @ptrFromInt(ptr);
    const slice = slice_ptr[0..len];
    allocator.free(slice);
}

var last_disassemble_len: usize = 0;

pub export fn disassemble_ptr(ptr: usize, len: usize) usize {
    const source_ptr: [*]const u8 = @ptrFromInt(ptr);
    const source = source_ptr[0..len];

    const result = @import("disassemble.zig").disassemble(allocator, source) catch {
        last_disassemble_len = 0;
        return 0;
    };

    last_disassemble_len = result.len;

    return @intFromPtr(result.ptr);
}

pub export fn disassemble_len() usize {
    return last_disassemble_len;
}

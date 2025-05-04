//! By convention, root.zig is the root source file when making a library. If
//! you are making an executable, the convention is to delete this file and
//! start with main.zig instead.
const std = @import("std");
const testing = std.testing;

pub export fn enable_stepper(axis: i32) callconv(.C) void {
    std.log.info("Enabling axis: {}", .{axis});
}
pub export fn disable_stepper(axis: i32) callconv(.C) void {
    std.log.info("Disabling axis: {}", .{axis});
}

pub export fn enqueue_command(x: f32, y: f32, z: f32, e: f32, index: i32, safe_stop: i32) callconv(.C) void {
    _ = index;
    std.log.info("Move cmd: X={} Y={} Z={}, E={}", .{ x, y, z, e });
    if (safe_stop != 0) {
        std.log.info("Safe Stop here", .{});
    }
}

// test "basic add functionality" {
//     try testing.expect(add(3, 7) == 10);
// }

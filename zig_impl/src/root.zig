//! By convention, root.zig is the root source file when making a library. If
//! you are making an executable, the convention is to delete this file and
//! start with main.zig instead.
const std = @import("std");
const testing = std.testing;

// pub const std_options: std.Options = .{
//     .log_level = .debug,
// };

var gpa = std.heap.GeneralPurposeAllocator(.{}).init;

const AxisMoveCmd = struct {
    pos: f32,
    vel: f32,
    acc: f32,
    jerk: f32,
    snap: f32,
    crackle: f32,
};
const MoveCmd = struct {
    X: AxisMoveCmd,
    Y: AxisMoveCmd,
    Z: AxisMoveCmd,
    E: AxisMoveCmd,
};

const Server = struct {
    run_thread: bool = false,
    pub fn run(self: *@This()) void {
        std.log.info("Starting server", .{});
        while (self.run_thread) {
            std.log.info("Running main server thread", .{});
            std.Thread.sleep(1e9);
        }
        std.log.info("We're done", .{});
    }
};

var server: Server = .{
    // .dev_name = "/dev/ttyUSB0",
    .run_thread = false,
};

fn run_server() void {
    std.debug.print("Starting server\n", .{});
    server.run_thread = true;
    server.run();
}

pub export fn enable_stepper(axis: i32) callconv(.C) void {
    std.log.info("Enabling axis: {}", .{axis});
}
pub export fn disable_stepper(axis: i32) callconv(.C) void {
    std.log.info("Disabling axis: {}", .{axis});
}

pub export fn enqueue_command(x: f64, y: f64, z: f64, e: f64, index: i32, safe_stop: i32) callconv(.C) void {
    _ = index;
    std.log.warn("Move cmd: X={} Y={} Z={}, E={}", .{ x, y, z, e });
    if (safe_stop != 0) {
        std.log.warn("Safe Stop here", .{});
    }
}

pub export fn configure(interp_time: f32) callconv(.C) void {
    std.log.info("Configuring Server:", .{});
    std.log.info("sInterepolation time: {}", .{interp_time});
    var thread_config = std.Thread.SpawnConfig{};
    thread_config.allocator = std.heap.c_allocator;
    const thread = std.Thread.spawn(thread_config, run_server, .{}) catch {
        std.log.err("Server thread failed to start!:", .{});
        return;
    };
    thread.detach();
    std.log.info("Finished Configuring Server", .{});
}

pub export fn shutdown() callconv(.C) void {
    std.log.info("Turning off Motors", .{});
}

test "startup shutdown" {
    const expect = std.testing.expect;
    configure(1e-4);
    std.Thread.sleep(1e9);
    try expect(server.run_thread == true);
    shutdown();
    try expect(server.run_thread == false);
}

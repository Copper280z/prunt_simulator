const std = @import("std");
const zzplot = @import("zzplot");
pub const Figure = zzplot.Figure;
pub const Axes = zzplot.Axes;
pub const Plot = zzplot.Plot;
pub const Color = zzplot.Color;
pub const nvg = zzplot.nanovg;
const minMax = zzplot.minMax;

const root = @import("root.zig");
const types = @import("types.zig");

const AxisMoveCmd = types.AxisMoveCmd;
const MoveCmd = types.MoveCmd;

const c = @cImport({
    @cInclude("glad/glad.h");
    @cInclude("GLFW/glfw3.h");
});

pub fn PlotMove(move_data: []const MoveCmd, Ts: f32, allocator: std.mem.Allocator) !void {
    if (move_data.len <= 10) return;
    const local_move_data = try allocator.alloc(MoveCmd, move_data.len);
    std.mem.copyForwards(MoveCmd, local_move_data, move_data);

    var thread_config = std.Thread.SpawnConfig{};
    thread_config.allocator = allocator;
    const thread = std.Thread.spawn(thread_config, run_plot, .{ local_move_data, Ts, allocator }) catch {
        std.log.err("Server thread failed to start!:", .{});
        return;
    };
    thread.detach();
    std.log.info("Finished Configuring Server", .{});
}

fn run_plot(move_data: []MoveCmd, Ts: f32, _allocator: std.mem.Allocator) void {
    var arena = std.heap.ArenaAllocator.init(_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    // generate data to plot
    const n_pts = move_data.len;
    const t: []f32 = allocator.alloc(f32, n_pts) catch {
        return;
    };
    const x: []f32 = allocator.alloc(f32, n_pts) catch {
        return;
    };
    const y: []f32 = allocator.alloc(f32, n_pts) catch {
        return;
    };
    const vx: []f32 = allocator.alloc(f32, n_pts) catch {
        return;
    };
    const vy: []f32 = allocator.alloc(f32, n_pts) catch {
        return;
    };
    const ax: []f32 = allocator.alloc(f32, n_pts) catch {
        return;
    };
    const ay: []f32 = allocator.alloc(f32, n_pts) catch {
        return;
    };
    const jx: []f32 = allocator.alloc(f32, n_pts) catch {
        return;
    };
    const jy: []f32 = allocator.alloc(f32, n_pts) catch {
        return;
    };
    const sx: []f32 = allocator.alloc(f32, n_pts) catch {
        return;
    };
    const sy: []f32 = allocator.alloc(f32, n_pts) catch {
        return;
    };
    std.log.warn("Plotting {} data points", .{move_data.len});
    for (0.., move_data) |i, move| {
        const i_f: f32 = @floatFromInt(i);
        t[i] = i_f * Ts;
        x[i] = move.X.pos;
        y[i] = move.Y.pos;
        vx[i] = move.X.vel;
        vy[i] = move.Y.vel;
        ax[i] = move.X.acc;
        ay[i] = move.Y.acc;
        jx[i] = move.X.jerk;
        jy[i] = move.Y.jerk;
        sx[i] = move.X.snap;
        sy[i] = move.Y.snap;
    }
    // try genTestSignals(t, vx, vy, x, y);

    // needed for when using multiple windows
    const shared = zzplot.createShared() catch {
        return;
    };

    // nvg context creation goes after gladLoadGL
    const vg = nvg.gl.init(allocator, .{
        .debug = true,
    }) catch {
        return;
    };

    zzplot.Font.init(vg);
    // defer vg.deinit();  // DO NOT UNCOMMENT THIS LINE, WILL GIVE ERROR UPON EXIT

    // create figure with two sets of axes
    var fig = Figure.init(allocator, shared, vg, .{
        .title_str = "Mulitple plots on multiple axes, with custom aesthetics",
        .xpos = 80,
        .ypos = 80,
        .wid = 960,
        .ht = 900,
        .disp_fps = true,
    }) catch {
        return;
    };

    var ax1 = Axes.init(fig, .{
        .ypos = 0.8,
        .ht = 0.2,
        .title_str = "Position",
        .xlabel_str = "time (s)",
        .ylabel_str = "mm",
        .draw_grid = true,
    }) catch {
        return;
    };

    var ax2 = Axes.init(fig, .{
        .ypos = 0.6,
        .ht = 0.2,
        .title_str = "Velocity",
        .xlabel_str = "time (s)",
        .ylabel_str = "mm/s",
        .draw_grid = true,
    }) catch {
        return;
    };
    var ax3 = Axes.init(fig, .{
        .ypos = 0.4,
        .ht = 0.2,
        .title_str = "Acceleration",
        .xlabel_str = "time (s)",
        .ylabel_str = "mm/s^2",
        .draw_grid = true,
    }) catch {
        return;
    };
    var ax4 = Axes.init(fig, .{
        .ypos = 0.2,
        .ht = 0.2,
        .title_str = "Jerk",
        .xlabel_str = "time (s)",
        .ylabel_str = "mm/s^3",
        .draw_grid = true,
    }) catch {
        return;
    };
    var ax5 = Axes.init(fig, .{
        .ypos = 0.0,
        .ht = 0.2,
        .title_str = "Snap",
        .xlabel_str = "time (s)",
        .ylabel_str = "mm/s^4",
        .draw_grid = true,
    }) catch {
        return;
    };

    // x and y will be plotted on the second axes
    var plt_x = Plot.init(ax1, .{ .line_col = Color.opacity(Color.green, 0.7), .line_width = 8 }) catch {
        return;
    };

    var plt_y = Plot.init(ax1, .{ .line_col = Color.opacity(Color.purple, 0.7), .line_width = 8 }) catch {
        return;
    };
    var plt_vx = Plot.init(ax2, .{ .line_col = Color.opacity(Color.blue, 0.7), .line_width = 8 }) catch {
        return;
    };

    var plt_vy = Plot.init(ax2, .{ .line_col = Color.opacity(Color.orange, 0.7), .line_width = 8 }) catch {
        return;
    };
    var plt_ax = Plot.init(ax3, .{ .line_col = Color.opacity(Color.blue, 0.7), .line_width = 8 }) catch {
        return;
    };

    var plt_ay = Plot.init(ax3, .{ .line_col = Color.opacity(Color.orange, 0.7), .line_width = 8 }) catch {
        return;
    };
    var plt_jx = Plot.init(ax4, .{ .line_col = Color.opacity(Color.blue, 0.7), .line_width = 8 }) catch {
        return;
    };

    var plt_jy = Plot.init(ax4, .{ .line_col = Color.opacity(Color.orange, 0.7), .line_width = 8 }) catch {
        return;
    };
    var plt_sx = Plot.init(ax5, .{ .line_col = Color.opacity(Color.blue, 0.7), .line_width = 8 }) catch {
        return;
    };

    var plt_sy = Plot.init(ax5, .{ .line_col = Color.opacity(Color.orange, 0.7), .line_width = 8 }) catch {
        return;
    };

    // we can set axis limits based on values of data using set_limits
    // minMax will find min and max values over an arbitrary number of slices

    // the final argument of set_limits allows use of custom tick computation methods
    // here, setting m_targets allows denser ticks
    ax1.set_limits(minMax(f32, .{t}), minMax(f32, .{ x, y }), .{ .m_target = 18 });

    ax2.set_limits(minMax(f32, .{t}), minMax(f32, .{ vx, vy }), .{});
    ax3.set_limits(minMax(f32, .{t}), minMax(f32, .{ ax, ay }), .{});
    ax4.set_limits(minMax(f32, .{t}), minMax(f32, .{ jx, jy }), .{});
    ax5.set_limits(minMax(f32, .{t}), minMax(f32, .{ sx, sy }), .{});

    while (fig.live and 0 == c.glfwWindowShouldClose(@ptrCast(fig.window))) {
        fig.begin();

        ax1.draw();
        plt_x.plot(t, x);
        plt_y.plot(t, y);

        ax2.draw();
        plt_vx.plot(t, vx);
        plt_vy.plot(t, vy);

        ax3.draw();
        plt_ax.plot(t, ax);
        plt_ay.plot(t, ay);

        ax4.draw();
        plt_jx.plot(t, jx);
        plt_jy.plot(t, jy);

        ax5.draw();
        plt_sx.plot(t, sx);
        plt_sy.plot(t, sy);

        fig.end();
    }
    allocator.free(move_data);
    c.glfwTerminate();
}

const math = std.math;

pub fn genTestSignals(t: []f32, u: []f32, v: []f32, x: []f32, y: []f32) !void {
    const n_pts = t.len;

    var i: usize = 0;
    while (i < n_pts) : (i += 1) {
        t[i] = math.pi * @as(f32, @floatFromInt(i)) / @as(f32, @floatFromInt(n_pts));

        u[i] = 9.7 * math.sin(10.6 * t[i] - 0.3);
        v[i] = 7.3 * t[i] * math.sin(3.1 * t[i] + 1.2);
        x[i] = 4.3 * math.sin(10.6 * t[i] + 0.3);
        y[i] = 0.06 * (2.1 * math.sin(18.6 * t[i] - 0.2) * 3.2 * x[i] * x[i]);
    }
}

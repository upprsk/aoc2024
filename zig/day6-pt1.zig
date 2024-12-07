const std = @import("std");

const p = std.debug.print;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const alloc = gpa.allocator();

    const cwd = std.fs.cwd();
    const path = try std.fs.path.join(alloc, &.{ "inputs", "day6.txt" });
    defer alloc.free(path);

    const input = try cwd.readFileAlloc(alloc, path, std.math.maxInt(u16));
    defer alloc.free(input);

    const m = try Map.parseString(input, alloc);
    defer m.deinit(alloc);

    var guard = m.findGuard().?;
    var dir = Direction.Up;

    var visits = std.AutoHashMap(Vec2, void).init(alloc);
    defer visits.deinit();

    // p("{}\n", .{guard});

    while (try m.step(guard, dir, &visits)) |next| {
        guard = next.newPos;
        dir = next.dir;

        // p("{}\n", .{guard});
    }

    // for (m.lines, 0..) |line, y| {
    //     for (line, 0..) |c, x| {
    //         if (visits.get(.{ .x = @intCast(x), .y = @intCast(y) })) |_| {
    //             p("X", .{});
    //         } else {
    //             p("{c}", .{c});
    //         }
    //     }
    //
    //     p("\n", .{});
    // }

    p("{}\n", .{visits.count()});
}

const Map = struct {
    lines: []const []const u8,

    fn parseString(input: []const u8, alloc: std.mem.Allocator) !Map {
        var lines = std.ArrayList([]const u8).init(alloc);

        var it = std.mem.split(u8, input, "\n");
        while (it.next()) |line| {
            if (line.len > 0) try lines.append(line);
        }

        return .{ .lines = try lines.toOwnedSlice() };
    }

    fn deinit(self: Map, alloc: std.mem.Allocator) void {
        alloc.free(self.lines);
    }

    fn findGuard(self: Map) ?Vec2 {
        for (self.lines, 0..) |line, y| {
            for (line, 0..) |c, x| {
                if (c == '^') return .{
                    .x = @intCast(x),
                    .y = @intCast(y),
                };
            }
        }

        return null;
    }

    fn getBounds(self: Map) Vec2 {
        return .{
            .y = @intCast(self.lines.len),
            .x = @intCast(self.lines[0].len),
        };
    }

    fn get(self: Map, pos: Vec2) ?u8 {
        const bounds = self.getBounds();
        return if (pos.containedBy(.{ .x = 0, .y = 0 }, bounds))
            self.lines[@intCast(pos.y)][@intCast(pos.x)]
        else
            null;
    }

    fn step(
        self: Map,
        pos: Vec2,
        dir: Direction,
        visits: *std.AutoHashMap(Vec2, void),
    ) !?struct { newPos: Vec2, dir: Direction } {
        const nextPos = pos.add(deltaForDirection(dir));
        const cell = self.get(nextPos) orelse {
            try visits.put(pos, {});
            return null;
        };

        if (cell == '#') return self.step(pos, dir.next(), visits);

        try visits.put(pos, {});
        if (!nextPos.containedBy(.{ .x = 0, .y = 0 }, self.getBounds())) {
            return null;
        }

        return .{ .newPos = nextPos, .dir = dir };
    }

    fn deltaForDirection(dir: Direction) Vec2 {
        return switch (dir) {
            .Up => .{ .x = 0, .y = -1 },
            .Down => .{ .x = 0, .y = 1 },
            .Left => .{ .x = -1, .y = 0 },
            .Right => .{ .x = 1, .y = 0 },
        };
    }
};

const Vec2 = struct {
    x: i32,
    y: i32,

    fn add(a: Vec2, b: Vec2) Vec2 {
        return .{ .x = a.x + b.x, .y = a.y + b.y };
    }

    inline fn containedBy(point: Vec2, topLeft: Vec2, bottomRight: Vec2) bool {
        return point.x >= topLeft.x and
            point.y >= topLeft.y and
            point.x < bottomRight.x and
            point.y < bottomRight.y;
    }
};

const Direction = enum {
    Up,
    Right,
    Down,
    Left,

    fn next(d: Direction) Direction {
        return if (d == .Left) .Up else @enumFromInt(@intFromEnum(d) + 1);
    }
};

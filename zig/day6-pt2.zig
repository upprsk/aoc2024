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

    var arena = std.heap.ArenaAllocator.init(alloc);
    defer arena.deinit();

    const limit = 10_000;

    var viable: usize = 0;

    var mutation = Vec2{ .x = 0, .y = 0 };
    while (try permuteMap(input, &mutation, arena.allocator())) |m| {
        if (!runTimeline(m, limit)) {
            p("found viable timeline {}\n", .{mutation});
            viable += 1;
        }

        // p("got result\n", .{});
        // for (m.lines) |line| {
        //     p("{s}\n", .{line});
        // }
    }

    p("{}\n", .{viable});
}

fn runTimeline(m: Map, limit: usize) bool {
    var guard = m.findGuard().?;
    var dir = Direction.Up;

    var iterations: usize = 0;
    while (try m.step(guard, dir)) |next| : (iterations += 1) {
        if (iterations > limit) return false;

        guard = next.newPos;
        dir = next.dir;
    }

    return true;
}

fn permuteMap(base: []const u8, mutation: *Vec2, alloc: std.mem.Allocator) !?Map {
    const copy = try alloc.dupe(u8, base);
    errdefer alloc.free(copy);

    std.mem.copyForwards(u8, copy, base);

    const lines = try Map.parseIntoLinesMut(copy, alloc);

    const initial_position = Map.init(lines).findGuard().?;
    if (mutation.eq(initial_position)) {
        mutation.* = nextMutation(
            mutation.*,
            Map.init(lines).getBounds(),
        ) orelse return null;

        return permuteMap(base, mutation, alloc);
    }

    lines[@intCast(mutation.y)][@intCast(mutation.x)] = '#';
    mutation.* = nextMutation(
        mutation.*,
        Map.init(lines).getBounds(),
    ) orelse return null;

    return Map.init(lines);
}

fn nextMutation(pos: Vec2, bounds: Vec2) ?Vec2 {
    var newPos = pos.add(.{ .x = 1, .y = 0 });
    if (newPos.x >= bounds.x) {
        newPos.x = 0;
        newPos.y += 1;
        if (newPos.y >= bounds.y) return null;
    }

    return newPos;
}

const Map = struct {
    lines: []const []const u8,

    fn init(lines: []const []const u8) Map {
        return .{ .lines = lines };
    }

    fn parseString(input: []const u8, alloc: std.mem.Allocator) !Map {
        var lines = std.ArrayList([]const u8).init(alloc);
        errdefer lines.deinit();

        var it = std.mem.split(u8, input, "\n");
        while (it.next()) |line| {
            if (line.len > 0) try lines.append(line);
        }

        return Map.init(try lines.toOwnedSlice());
    }

    fn parseIntoLinesMut(input: []u8, alloc: std.mem.Allocator) ![][]u8 {
        var lines = std.ArrayList([]u8).init(alloc);
        errdefer lines.deinit();

        var it = std.mem.split(u8, input, "\n");
        while (it.next()) |line| {
            const start_idx = @intFromPtr(line.ptr) - @intFromPtr(input.ptr);

            if (line.len > 0)
                try lines.append(input[start_idx .. start_idx + line.len]);
        }

        return try lines.toOwnedSlice();
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
    ) !?struct { newPos: Vec2, dir: Direction } {
        const nextPos = pos.add(deltaForDirection(dir));
        const cell = self.get(nextPos) orelse return null;

        if (cell == '#') return self.step(pos, dir.next());

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

    fn eq(a: Vec2, b: Vec2) bool {
        return a.x == b.x and a.y == b.y;
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

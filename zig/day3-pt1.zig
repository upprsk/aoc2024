const std = @import("std");

const p = std.debug.print;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const alloc = gpa.allocator();

    const cwd = std.fs.cwd();
    const path = try std.fs.path.join(alloc, &.{ "inputs", "day3.txt" });
    defer alloc.free(path);

    const input = try cwd.readFileAlloc(alloc, path, std.math.maxInt(u16));
    defer alloc.free(input);

    var sum: i32 = 0;
    var m = Matcher.init(input);
    while (m.next()) |result| {
        if (result.ok)
            sum += result.a * result.b;
    }

    p("{}\n", .{sum});
}

const Matcher = struct {
    const Result = struct { ok: bool = false, a: i32 = 0, b: i32 = 0 };

    fn init(input: []const u8) Matcher {
        return .{ .s = input };
    }

    fn empty(m: Matcher) ?Result {
        if (m.s.len == 0) return null;
        return .{};
    }

    fn next(m: *Matcher) ?Result {
        if (!m.match('m')) return m.empty();
        if (!m.match('u')) return m.empty();
        if (!m.match('l')) return m.empty();
        if (!m.match('(')) return m.empty();

        const firstStart = m.s;
        while (m.matchDigit()) {}
        const first = firstStart[0 .. @intFromPtr(m.s.ptr) - @intFromPtr(firstStart.ptr)];

        if (!m.match(',')) return m.empty();

        const secondStart = m.s;
        while (m.matchDigit()) {}
        const second = secondStart[0 .. @intFromPtr(m.s.ptr) - @intFromPtr(secondStart.ptr)];

        if (!m.match(')')) return m.empty();

        const a = std.fmt.parseInt(i32, first, 10) catch return m.empty();
        const b = std.fmt.parseInt(i32, second, 10) catch return m.empty();

        return .{ .ok = true, .a = a, .b = b };
    }

    fn match(self: *Matcher, c: u8) bool {
        if (self.s.len < 1) return false;

        const eq = self.s[0] == c;
        self.s = self.s[1..];
        return eq;
    }

    fn matchDigit(self: *Matcher) bool {
        if (self.s.len < 1 or !std.ascii.isDigit(self.s[0])) return false;

        self.s = self.s[1..];
        return true;
    }

    s: []const u8,
};

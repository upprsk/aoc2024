const std = @import("std");

const p = std.debug.print;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const alloc = gpa.allocator();

    const cwd = std.fs.cwd();
    const path = try std.fs.path.join(alloc, &.{ "inputs", "day1.txt" });
    defer alloc.free(path);

    const input = try cwd.readFileAlloc(alloc, path, std.math.maxInt(u16));
    defer alloc.free(input);

    var left_locs = std.ArrayList(i32).init(alloc);
    defer left_locs.deinit();

    var right_locs = std.ArrayList(i32).init(alloc);
    defer right_locs.deinit();

    var lines = std.mem.split(u8, input, "\n");
    while (lines.next()) |line| {
        // skip empty lines (most likely just the last one)
        if (line.len == 0) continue;

        var cols = std.mem.split(u8, line, "   ");
        const left = cols.next().?;
        const right = cols.next().?;
        std.debug.assert(cols.next() == null);

        const left_int = try std.fmt.parseInt(i32, left, 10);
        const right_int = try std.fmt.parseInt(i32, right, 10);

        try left_locs.append(left_int);
        try right_locs.append(right_int);
    }

    const compare = struct {
        fn f(_: void, lhs: i32, rhs: i32) bool {
            return lhs < rhs;
        }
    }.f;

    std.mem.sort(i32, left_locs.items, {}, compare);
    std.mem.sort(i32, right_locs.items, {}, compare);

    var distance: u32 = 0;
    for (left_locs.items, right_locs.items) |left, right| {
        distance += @abs(left - right);
    }

    p("{}\n", .{distance});
}

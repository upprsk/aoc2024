const std = @import("std");

const p = std.debug.print;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const alloc = gpa.allocator();

    const cwd = std.fs.cwd();
    const path = try std.fs.path.join(alloc, &.{ "inputs", "day2.txt" });
    defer alloc.free(path);

    const input = try cwd.readFileAlloc(alloc, path, std.math.maxInt(u16));
    defer alloc.free(input);

    var safe: u32 = 0;

    var linenum: u32 = 0;
    var lines = std.mem.split(u8, input, "\n");
    while (lines.next()) |line| {
        linenum += 1;

        // skip empty lines (most likely just the last one)
        if (line.len == 0) continue;

        var levels = std.ArrayList(i32).init(alloc);
        defer levels.deinit();

        var cols = std.mem.split(u8, line, " ");
        while (cols.next()) |col| {
            const v = try std.fmt.parseInt(i32, col, 10);
            try levels.append(v);
        }

        const error_idx = checkLevels(levels.items);
        if (error_idx < 0) {
            // p("inputs/day2.txt:{}: {s} is safe\n", .{ linenum, @tagName(direction) });
            safe += 1;
            continue;
        }

        for (0..levels.items.len) |rem| {
            var temp = try levels.clone();
            defer temp.deinit();

            _ = temp.orderedRemove(rem);

            if (checkLevels(temp.items) < 0) {
                // p("inputs/day2.txt:{}: is safe after removing {}\n", .{ linenum, rem });
                safe += 1;
                break;
            }
        }
    }

    p("{}\n", .{safe});
}

/// Returns the index with the error, or -1 if everything is correct.
fn checkLevels(levels: []const i32) i32 {
    var error_idx: i32 = -1;

    // check if all are increasing
    var direction: enum { up, down, undefined } = .undefined;
    var prev = levels[0];
    for (levels[1..], 1..) |level, idx| {
        const diff = level - prev;
        prev = level;

        switch (direction) {
            .undefined => {
                direction = if (diff > 0 and @abs(diff) <= 3)
                    .up
                else if (diff < 0 and @abs(diff) <= 3)
                    .down
                else {
                    // p("inputs/day2.txt:{}: is unsafe because diff=0\n", .{linenum});
                    error_idx = @intCast(idx);
                    break;
                };
            },
            .up => {
                if (diff <= 0 or @abs(diff) > 3) {
                    // p("inputs/day2.txt:{}: UP is unsafe because diff={}\n", .{ linenum, diff });
                    error_idx = @intCast(idx);
                    break;
                }
            },
            .down => {
                if (diff >= 0 or @abs(diff) > 3) {
                    // p("inputs/day2.txt:{}: DOWN is unsafe because diff={}\n", .{ linenum, diff });
                    error_idx = @intCast(idx);
                    break;
                }
            },
        }
    }

    return error_idx;
}

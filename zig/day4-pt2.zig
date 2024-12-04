const std = @import("std");

const p = std.debug.print;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const alloc = gpa.allocator();

    const cwd = std.fs.cwd();
    const path = try std.fs.path.join(alloc, &.{ "inputs", "day4.txt" });
    defer alloc.free(path);

    const input = try cwd.readFileAlloc(alloc, path, std.math.maxInt(u16));
    defer alloc.free(input);

    var word_count: usize = 0;

    var lines = std.ArrayList([]const u8).init(alloc);
    defer lines.deinit();

    var lines_it = std.mem.split(u8, input, "\n");
    while (lines_it.next()) |line| {
        // skip empty lines (most likely just the last one)
        if (line.len == 0) continue;

        try lines.append(line);
    }

    for (0..lines.items.len - 2) |y| {
        for (0..lines.items[y].len - 2) |x| {
            // check for:
            // M.M
            // .A.
            // S.S
            if (lines.items[y + 0][x + 0] == 'M' and
                lines.items[y + 0][x + 2] == 'M' and
                lines.items[y + 1][x + 1] == 'A' and
                lines.items[y + 2][x + 0] == 'S' and
                lines.items[y + 2][x + 2] == 'S')
            {
                word_count += 1;
            }

            // check for:
            // S.M
            // .A.
            // S.M
            if (lines.items[y + 0][x + 0] == 'S' and
                lines.items[y + 0][x + 2] == 'M' and
                lines.items[y + 1][x + 1] == 'A' and
                lines.items[y + 2][x + 0] == 'S' and
                lines.items[y + 2][x + 2] == 'M')
            {
                word_count += 1;
            }

            // check for:
            // S.S
            // .A.
            // M.M
            if (lines.items[y + 0][x + 0] == 'S' and
                lines.items[y + 0][x + 2] == 'S' and
                lines.items[y + 1][x + 1] == 'A' and
                lines.items[y + 2][x + 0] == 'M' and
                lines.items[y + 2][x + 2] == 'M')
            {
                word_count += 1;
            }

            // check for:
            // M.S
            // .A.
            // M.S
            if (lines.items[y + 0][x + 0] == 'M' and
                lines.items[y + 0][x + 2] == 'S' and
                lines.items[y + 1][x + 1] == 'A' and
                lines.items[y + 2][x + 0] == 'M' and
                lines.items[y + 2][x + 2] == 'S')
            {
                word_count += 1;
            }
        }
    }

    p("{}\n", .{word_count});
}

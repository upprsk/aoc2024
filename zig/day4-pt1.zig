const std = @import("std");

const p = std.debug.print;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const alloc = gpa.allocator();

    var arena = std.heap.ArenaAllocator.init(alloc);
    defer arena.deinit();

    const temp = arena.allocator();

    const cwd = std.fs.cwd();
    const path = try std.fs.path.join(alloc, &.{ "inputs", "day4.test.txt" });
    defer alloc.free(path);

    const input = try cwd.readFileAlloc(alloc, path, std.math.maxInt(u16));
    defer alloc.free(input);

    var word_count: usize = 0;

    var by_lines = std.ArrayList([]const u8).init(alloc);
    defer by_lines.deinit();

    var by_cols = std.ArrayList(std.ArrayList(u8)).init(temp);

    var line_num: usize = 0;
    var lines = std.mem.split(u8, input, "\n");
    while (lines.next()) |line| {
        line_num += 1;

        // skip empty lines (most likely just the last one)
        if (line.len == 0) continue;

        try by_lines.append(line);

        // try to find the word normally
        word_count += findWord(line, "XMAS", line_num);
        // try to find the word reversed
        word_count += findWord(line, "SAMX", line_num);

        // create columns
        if (by_cols.items.len == 0) {
            for (0..line.len) |_|
                try by_cols.append(std.ArrayList(u8).init(temp));
        }

        for (line, 0..) |c, idx| {
            try by_cols.items[idx].append(c);
        }
    }

    // do the same as in the first loop, but now for the colums that we built
    for (by_cols.items) |col_al| {
        const col: []const u8 = col_al.items;

        // skip empty colums (most likely just the last one)
        if (col.len == 0) continue;

        // try to find the word normally
        word_count += findWord(col, "XMAS", 0);
        // try to find the word reversed
        word_count += findWord(col, "SAMX", 0);
    }

    const m = by_lines.items.len;
    const n = by_lines.items[0].len;
    for (0..n) |j| {
        var diagonal = std.ArrayList(u8).init(alloc);
        defer diagonal.deinit();

        var x: usize = 0;
        var y = j;
        while (x < m and y < n) : ({
            x += 1;
            y += 1;
        }) {
            try diagonal.append(by_lines.items[x][y]);
        }

        // try to find the word normally
        word_count += findWord(diagonal.items, "XMAS", 0);
        // try to find the word reversed
        word_count += findWord(diagonal.items, "SAMX", 0);
    }

    for (1..m) |i| {
        var diagonal = std.ArrayList(u8).init(alloc);
        defer diagonal.deinit();

        var x = i;
        var y: usize = 0;
        while (x < m and y < n) : ({
            x += 1;
            y += 1;
        }) {
            try diagonal.append(by_lines.items[x][y]);
        }

        // try to find the word normally
        word_count += findWord(diagonal.items, "XMAS", 0);
        // try to find the word reversed
        word_count += findWord(diagonal.items, "SAMX", 0);
    }

    for (0..n) |j| {
        var diagonal = std.ArrayList(u8).init(alloc);
        defer diagonal.deinit();

        var x: usize = 0;
        var y: isize = @intCast(j);
        while (x < m and y >= 0) : ({
            x += 1;
            y -= 1;
        }) {
            try diagonal.append(by_lines.items[x][@intCast(y)]);
        }

        // try to find the word normally
        word_count += findWord(diagonal.items, "XMAS", 0);
        // try to find the word reversed
        word_count += findWord(diagonal.items, "SAMX", 0);
    }

    for (1..m) |i| {
        var diagonal = std.ArrayList(u8).init(alloc);
        defer diagonal.deinit();

        var x = i;
        var y: isize = @intCast(n - 1);
        while (x < m and y < n) : ({
            x += 1;
            y -= 1;
        }) {
            try diagonal.append(by_lines.items[x][@intCast(y)]);
        }

        // try to find the word normally
        word_count += findWord(diagonal.items, "XMAS", 0);
        // try to find the word reversed
        word_count += findWord(diagonal.items, "SAMX", 0);
    }

    p("{}\n", .{word_count});
}

fn findWord(s: []const u8, word: []const u8, line_num: usize) usize {
    var word_count: usize = 0;
    var found_idx: usize = 0;
    var col: usize = 0;
    for (s) |c| {
        col += 1;
        if (c != word[found_idx]) {
            found_idx = 0;
        }

        if (c == word[found_idx]) {
            found_idx += 1;
        }

        if (found_idx == word.len) {
            p("inputs/day4.test.txt:{}: found \"{s}\"\n", .{ if (line_num == 0) col - word.len + 1 else line_num, word });
            found_idx = 0;
            word_count += 1;
        }
    }

    return word_count;
}

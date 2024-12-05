const std = @import("std");

const p = std.debug.print;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const alloc = gpa.allocator();

    const cwd = std.fs.cwd();
    const path = try std.fs.path.join(alloc, &.{ "inputs", "day5.txt" });
    defer alloc.free(path);

    const input = try cwd.readFileAlloc(alloc, path, std.math.maxInt(u16));
    defer alloc.free(input);

    var pr = PageRules.init(alloc);
    defer pr.deinit();

    var lines_it = std.mem.split(u8, input, "\n");

    // parse the page ordering rules
    while (lines_it.next()) |line| {
        // section divider, after this we go to the updates
        if (line.len == 0) break;

        try pr.putLine(line);
    }

    pr.prepare();

    var center_sum: u32 = 0;

    // parse the updates
    while (lines_it.next()) |line| {
        // ignore empty lines (probably just the last line)
        if (line.len == 0) continue;

        var updates = std.ArrayList(u32).init(alloc);
        defer updates.deinit();

        var updates_it = std.mem.split(u8, line, ",");
        while (updates_it.next()) |u| {
            const update = try std.fmt.parseInt(u32, u, 10);
            try updates.append(update);
        }

        var in_order = true;

        outer: for (updates.items, 0..) |u, i| {
            for (updates.items, 0..) |b, j| {
                // ignore ourselves
                if (j == i) continue;

                // p("{} should be before {}?\n", .{ u, b });

                if (pr.shouldBeBefore(u, b)) {
                    // p(". {} should be before {}\n", .{ u, b });

                    if (i < j) {
                        // p("# {} is before {} ({} < {})\n", .{ u, b, i, j });
                    } else {
                        // p(". {} should be before {}, but it is not ({} > {})\n", .{ u, b, i, j });
                        in_order = false;
                        break :outer;
                    }
                }
            }
        }

        if (!in_order) {
            outer: while (true) {
                for (updates.items, 0..) |u, i| {
                    for (updates.items, 0..) |b, j| {
                        // ignore ourselves
                        if (j == i) continue;

                        // p("{} should be before {}?\n", .{ u, b });

                        if (pr.shouldBeBefore(u, b)) {
                            // p(". {} should be before {}\n", .{ u, b });

                            if (i < j) {
                                // p("# {} is before {} ({} < {})\n", .{ u, b, i, j });
                            } else {
                                // p(". {} should be before {}, but it is not ({} > {})\n", .{ u, b, i, j });
                                std.mem.swap(u32, &updates.items[i], &updates.items[j]);
                                continue :outer;
                            }
                        }
                    }
                }

                break;
            }

            // p(". items before: \"{s}\", items now: {any}\n", .{ line, updates.items });

            in_order = true;

            outer: for (updates.items, 0..) |u, i| {
                for (updates.items, 0..) |b, j| {
                    // ignore ourselves
                    if (j == i) continue;

                    // p("{} should be before {}?\n", .{ u, b });

                    if (pr.shouldBeBefore(u, b)) {
                        // p(". {} should be before {}\n", .{ u, b });

                        if (i < j) {
                            // p("# {} is before {} ({} < {})\n", .{ u, b, i, j });
                        } else {
                            // p(". {} should be before {}, but it is not ({} > {})\n", .{ u, b, i, j });
                            in_order = false;
                            break :outer;
                        }
                    }
                }
            }

            std.debug.assert(in_order);

            // p("! in order: \"{any}\"\n", .{updates.items});
            const center_idx = updates.items.len / 2;
            // p("# center item is @{}: {}\n", .{ center_idx, updates.items[center_idx] });
            center_sum += updates.items[center_idx];
        }
    }

    p("{}\n", .{center_sum});
}

const PageRules = struct {
    const Pair = struct { u32, u32 };

    fn init(alloc: std.mem.Allocator) PageRules {
        return .{ .rules = std.ArrayList(Pair).init(alloc) };
    }

    fn deinit(self: *PageRules) void {
        self.rules.deinit();
    }

    fn prepare(self: *PageRules) void {
        std.mem.sort(Pair, self.rules.items, {}, struct {
            fn lt(_: void, lhs: Pair, rhs: Pair) bool {
                return lhs[0] < rhs[0];
            }
        }.lt);
    }

    fn put(self: *PageRules, before: u32, after: u32) !void {
        try self.rules.append(.{ before, after });
    }

    fn shouldBeBefore(self: *PageRules, update: u32, item: u32) bool {
        for (self.rules.items) |it| {
            const before = it[0];
            const after = it[1];
            // p("before,after={},{}\n", .{ before, after });

            // as the array is sorted, we can be sure that there are no more items
            // after this point that would match
            if (before > update) break;

            if (before == update and after == item) {
                return true;
            }
        }

        return false;
    }

    fn putLine(self: *PageRules, line: []const u8) !void {
        var parts = std.mem.split(u8, line, "|");
        const before = try std.fmt.parseInt(u32, parts.next().?, 10);
        const after = try std.fmt.parseInt(u32, parts.next().?, 10);
        std.debug.assert(parts.next() == null);

        try self.put(before, after);
    }

    rules: std.ArrayList(Pair),
};

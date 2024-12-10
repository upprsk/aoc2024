package main

import "core:bytes"
import "core:fmt"
import "core:mem"
import "core:os"
import "core:slice"
import "core:sort"
import "core:strconv"
import "core:strings"

Vec2 :: [2]int

main :: proc() {
	defer free_all(context.temp_allocator)

	filename :: "inputs/day10.txt"
	contents, ok := os.read_entire_file(filename)
	if !ok {
		fmt.eprintln("failed to read file:", filename)
		os.exit(1)
	}

	defer delete(contents)

	topo := bytes.split(contents, []u8{'\n'}, context.temp_allocator)
	topo = slice.filter(topo, proc(line: []u8) -> bool {return len(line) != 0})
	defer delete(topo)

	for line in topo {
		for &b in line {
			b = digit_to_int(b)
		}
	}

	starts := find_trail_starts(topo)
	defer delete(starts)

	sum: int

	for start in starts {
		sum += walk_trail(topo, start)
	}

	fmt.println(sum)
}

walk_trail :: proc(m: [][]u8, start: Vec2) -> (score: int) {
	bounds := Vec2{len(m[0]), len(m)}

	queue := [dynamic]Vec2{start}
	defer delete(queue)

	for len(queue) > 0 {
		item := pop(&queue)

		h := m[item.y][item.x]
		if h == 9 {
			score += 1
			continue
		}

		// fmt.println("item=", item, "@=", h)

		neighbors := get_neighbors(item, bounds, context.temp_allocator)
		for n in neighbors {
			if m[n.y][n.x] == h + 1 {
				// fmt.println("appending:", n)
				append(&queue, n)
			}
		}
	}

	return
}

get_neighbors :: proc(loc, bounds: Vec2, allocator := context.allocator) -> []Vec2 {
	values := [?]Vec2{loc + {0, -1}, loc + {-1, 0}, loc + {1, 0}, loc + {0, 1}}

	result := make([dynamic]Vec2, allocator)
	for v in values {
		if v.x >= 0 && v.y >= 0 && v.x < bounds.x && v.y < bounds.y {
			append(&result, v)
		}
	}

	return result[:]
}

find_trail_starts :: proc(m: [][]u8) -> []Vec2 {
	items: [dynamic]Vec2

	for line, y in m {
		for b, x in line {
			if b == 0 {
				append(&items, Vec2{x, y})
			}
		}
	}

	return items[:]
}

digit_to_int :: proc(c: u8) -> u8 {
	return c - '0'
}

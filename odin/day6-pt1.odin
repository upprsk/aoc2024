package main

import "core:fmt"
import "core:mem"
import "core:os"
import "core:slice"
import "core:sort"
import "core:strconv"
import "core:strings"

main :: proc() {
	filename :: "inputs/day6.txt"
	contents, ok := os.read_entire_file(filename)
	if !ok {
		fmt.eprintln("failed to read file:", filename)
		os.exit(1)
	}

	defer delete(contents)

	temp_ascii_map := strings.split_lines(string(contents), context.temp_allocator)
	ascii_map := slice.filter(temp_ascii_map, proc(line: string) -> bool {return line != ""})
	defer delete(ascii_map)

	m, n := len(ascii_map), len(ascii_map[0])

	guard, guard_found := find_guard(ascii_map)
	assert(guard_found)

	positions := make(map[Vec2]bool)
	defer delete(positions)

	facing: Direction
	positions[guard] = true

	for guard.x >= 0 && guard.y >= 0 && guard.x < n && guard.y < m {
		guard, facing = step(guard, facing, ascii_map, &positions)
	}

	fmt.println(len(positions))
}

Vec2 :: distinct [2]int
Direction :: enum {
	Up,
	Right,
	Down,
	Left,
}

find_guard :: proc(m: []string) -> (Vec2, bool) {
	for line, y in m {
		for c, x in line {
			if c == '^' {
				return Vec2{x, y}, true
			}
		}
	}

	return Vec2{}, false
}

step :: proc(
	pos: Vec2,
	facing: Direction,
	m: []string,
	positions: ^map[Vec2]bool,
) -> (
	p: Vec2,
	d: Direction,
) {
	p = pos
	d = facing

	switch d {
	case .Up:
		p.y -= 1
	case .Down:
		p.y += 1
	case .Left:
		p.x -= 1
	case .Right:
		p.x += 1
	}

	// fmt.println(p, d)
	h, w := len(m), len(m[0])

	if p.x >= 0 && p.y >= 0 && p.y < h && p.x < w {
		if m[p.y][p.x] == '#' {
			// change direction and go again

			if d == .Left {
				d = .Up
			} else {
				d = Direction(int(d) + 1)
			}

			// fmt.println("  turn", d)
			return step(pos, d, m, positions)
		}

		positions[p] = true
	}

	return
}

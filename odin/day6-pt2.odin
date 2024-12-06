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

	possible_timelines: int

	obstacle: Vec2
	ascii_map := strings.clone(string(contents))
	defer delete(ascii_map)

	{
		first_map := parse_map(ascii_map)
		defer delete(first_map)

		// for line in first_map {
		// 	fmt.println(line)
		// }
		// fmt.println("simulating...")

		if !simulate_timeline(first_map, len(first_map) * len(first_map[0])) {
			possible_timelines += 1
		}
	}

	for new_map in permute_map(ascii_map, &obstacle) {
		defer {
			delete(new_map)
			delete(ascii_map)
			ascii_map = strings.clone(string(contents))
		}

		// for line in new_map {
		// 	fmt.println(line)
		// }
		// fmt.printfln("simulating %v (of %v)...", obstacle, Vec2{len(new_map), len(new_map[0])})

		// we spin a **lot** to make sure that it is impossible to escape the obstacle we placed
		if !simulate_timeline(new_map, len(new_map) * len(new_map[0])) {
			fmt.printfln("found viable timeline: %v...", obstacle)
			possible_timelines += 1
		}
	}

	fmt.println(possible_timelines)
}

parse_map :: proc(s: string) -> []string {
	temp_ascii_map := strings.split_lines(s, context.temp_allocator)
	return slice.filter(temp_ascii_map, proc(line: string) -> bool {return line != ""})
}

permute_map :: proc(original: string, obstacle: ^Vec2) -> ([]string, bool) {
	ascii_map := parse_map(original)
	bounds := Vec2{len(ascii_map), len(ascii_map[0])}
	if obstacle.y >= bounds.y {
		return nil, false
	}

	starting_location, found_guard := find_guard(ascii_map)
	assert(found_guard)

	if obstacle^ == starting_location {
		ok: bool
		obstacle^, ok = next_obstacle(obstacle^, bounds)
		if !ok do return nil, false

		return permute_map(original, obstacle)
	}

	cpy := transmute([]u8)ascii_map[obstacle.y]
	cpy[obstacle.x] = '#'

	obstacle^, _ = next_obstacle(obstacle^, bounds)
	return ascii_map, true
}

next_obstacle :: proc(obstacle, bounds: Vec2) -> (o: Vec2, ok: bool = true) {
	o = obstacle

	o.x += 1
	if o.x >= bounds.x {
		o.x = 0
		o.y += 1
		if o.y >= bounds.y {
			ok = false
			return
		}
	}

	return
}

Vec2 :: distinct [2]int
Direction :: enum {
	Up,
	Right,
	Down,
	Left,
}

simulate_timeline :: proc(ascii_map: []string, limit: int) -> bool {
	m, n := len(ascii_map), len(ascii_map[0])

	guard, guard_found := find_guard(ascii_map)
	assert(guard_found)

	positions := make(map[Vec2]bool)
	defer delete(positions)

	facing: Direction
	positions[guard] = true

	counter := 0
	for ; guard.x >= 0 && guard.y >= 0 && guard.x < n && guard.y < m; counter += 1 {
		if counter > limit {
			// fmt.println("did not escape after", counter, "iterations")
			return false
		}

		guard, facing = step(guard, facing, ascii_map, &positions)
	}

	// fmt.println("escaped after", counter, "iterations")
	return true
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

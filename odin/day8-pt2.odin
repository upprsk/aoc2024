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
	filename :: "inputs/day8.txt"
	contents, ok := os.read_entire_file(filename)
	if !ok {
		fmt.eprintln("failed to read file:", filename)
		os.exit(1)
	}

	defer delete(contents)

	sum: int

	city := bytes.split(contents, transmute([]u8)string("\n"), context.temp_allocator)
	city = slice.filter(city, proc(s: []u8) -> bool {return len(s) > 0})
	defer delete(city)

	// print_empty_city_map(city)

	all_anti := make(map[Vec2]bool)

	for line, y in city {
		for c, x in line {
			if c == '.' do continue

			v := Vec2{x, y}

			anti := find_antinodes(city, c, v)
			defer delete(anti)

			// fmt.println(rune(c), v)
			// print_city_map_with_antinodes(city, v, anti)

			for k, v in anti {
				all_anti[k] = v
			}
		}
	}

	// print_city_map_with_antinodes(city, Vec2{-1, -1}, all_anti)
	fmt.println(len(all_anti))
}

print_empty_city_map :: proc(m: [][]u8) {
	for line in m {
		fmt.println(string(line))
	}
}

print_city_map_with_antinodes :: proc(m: [][]u8, pos: Vec2, antinodes: map[Vec2]bool, h := '#') {
	for line, y in m {
		for c, x in line {
			v := Vec2{x, y}
			if _, found := antinodes[v]; found {
				fmt.print(h)
			} else if v == pos {
				fmt.print('X')
			} else {
				fmt.print(rune(c))
			}
		}

		fmt.println()
	}
}

print_city_map_with_highlight :: proc(m: [][]u8, highlight: Vec2, h := '#') {
	for line, y in m {
		for c, x in line {
			v := Vec2{x, y}
			if v == highlight {
				fmt.print(h)
			} else {
				fmt.print(rune(c))
			}
		}

		fmt.println()
	}
}

find_antinodes :: proc(m: [][]u8, co: u8, pos: Vec2) -> map[Vec2]bool {
	bounds := Vec2{len(m[0]), len(m)}
	antinodes := make(map[Vec2]bool)

	for line, y in m {
		for c, x in line {
			v := Vec2{x, y}

			// if this is us, ignore
			if v == pos do continue

			// if it is another antenna of the same frequency, find the antinodes
			if c == co {
				for a := pos;
				    a.x >= 0 && a.y >= 0 && a.x < bounds.x && a.y < bounds.y;
				    a, v = a * 2 - v, a {
					antinodes[a] = true
				}
			}
		}
	}

	return antinodes
}

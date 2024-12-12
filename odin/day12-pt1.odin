package main

import "core:bytes"
import "core:fmt"
import "core:math"
import "core:mem"
import "core:os"
import "core:slice"
import "core:sort"
import "core:strconv"
import "core:strings"

main :: proc() {
	defer free_all(context.temp_allocator)

	filename :: "inputs/day12.txt"
	contents, ok := os.read_entire_file(filename)
	if !ok {
		fmt.eprintln("failed to read file:", filename)
		os.exit(1)
	}

	defer delete(contents)

	m := strings.split_lines(string(contents), context.temp_allocator)
	m = slice.filter(m, proc(s: string) -> bool {return len(s) != 0})
	defer delete(m)

	visited := make(map[Vec2]u8)
	defer delete(visited)

	price: int

	for line, y in m {
		for c, x in line {
			if visited[{x, y}] == 0 {
				rel: [dynamic]Sides

				// fmt.println("initial", c)
				fr := flood_for(m, &visited, {x, y}, line[x])
				price += fr.area * fr.perimeter
			}
		}
	}

	fmt.println(price)
}

FloodResult :: struct {
	area:      int,
	perimeter: int,
}

flood_for :: proc(m: []string, visited: ^map[Vec2]u8, pos: Vec2, c: u8) -> FloodResult {
	bounds := Vec2{len(m[0]), len(m)}
	neighbors := get_neighbors(pos, bounds)
	defer delete(neighbors)

	// fmt.println("visited", pos, rune(c))
	visited[pos] = c

	area: int
	perimeter: int
	sides: Sides

	for n in neighbors {
		if m[n.pos.y][n.pos.x] == c {
			if visited[n.pos] == 0 {
				// fmt.println("flooding", n)
				r := flood_for(m, visited, n.pos, c)
				area += r.area
				perimeter += r.perimeter
			}

			sides += {n.side}
		}
	}

	free_sides := 4 - card(sides)
	return {area + 1, perimeter + free_sides}
}

Vec2 :: [2]int

Sides :: bit_set[Side]
Side :: enum {
	North,
	East,
	South,
	West,
}

Neighbor :: struct {
	pos:  Vec2,
	side: Side,
}

get_neighbors :: proc(loc, bounds: Vec2, allocator := context.allocator) -> []Neighbor {
	values := [?]Neighbor {
		{loc + {0, -1}, .North},
		{loc + {1, 0}, .East},
		{loc + {0, 1}, .South},
		{loc + {-1, 0}, .West},
	}

	result := make([dynamic]Neighbor, allocator)
	for v in values {
		if v.pos.x >= 0 && v.pos.y >= 0 && v.pos.x < bounds.x && v.pos.y < bounds.y {
			append(&result, v)
		}
	}

	return result[:]
}

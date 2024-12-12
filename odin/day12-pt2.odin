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
				defer delete(fr.sides)

				// fmt.println(c, fr.area)

				plots := make(map[Vec2]PlotSides)
				defer delete(plots)

				minpos: Vec2 = {1 << 32, 1 << 32}
				maxpos: Vec2
				for s in fr.sides {
					minpos.x = min(minpos.x, s.pos.x)
					minpos.y = min(minpos.y, s.pos.y)
					maxpos.x = max(maxpos.x, s.pos.x)
					maxpos.y = max(maxpos.y, s.pos.y)

					plots[s.pos] = s
				}

				// fmt.println("minmax:", minpos, maxpos)

				side_count: int = 0

				for y in minpos.y ..= maxpos.y {
					last_sides: Sides

					for x in minpos.x ..= maxpos.x {
						if p, ok := plots[{x, y}]; ok {
							if .North not_in last_sides && .North in p.sides {
								side_count += 1
							}

							if .South not_in last_sides && .South in p.sides {
								side_count += 1
							}

							last_sides = p.sides
						} else {
							last_sides = {}
						}
					}
				}

				// fmt.println("horizontal:", side_count)

				for x in minpos.x ..= maxpos.x {
					last_sides: Sides

					for y in minpos.y ..= maxpos.y {
						if p, ok := plots[{x, y}]; ok {
							if .West not_in last_sides && .West in p.sides {
								side_count += 1
							}

							if .East not_in last_sides && .East in p.sides {
								side_count += 1
							}

							last_sides = p.sides
						} else {
							last_sides = {}
						}
					}
				}

				// fmt.println("horizontal+vertical:", side_count)

				price += fr.area * side_count
			}
		}
	}

	fmt.println(price)
}

FloodResult :: struct {
	area:  int,
	sides: []PlotSides,
}

PlotSides :: struct {
	pos:   Vec2,
	sides: Sides,
}

flood_for :: proc(m: []string, visited: ^map[Vec2]u8, pos: Vec2, c: u8) -> FloodResult {
	bounds := Vec2{len(m[0]), len(m)}
	neighbors := get_neighbors(pos, bounds)
	defer delete(neighbors)

	// fmt.println("visited", pos, rune(c))
	visited[pos] = c

	FULL_SET :: Sides{.North, .East, .South, .West}

	all_sides: [dynamic]PlotSides

	area: int
	sides: Sides

	for n in neighbors {
		if m[n.pos.y][n.pos.x] == c {
			if visited[n.pos] == 0 {
				// fmt.println("flooding", n)
				r := flood_for(m, visited, n.pos, c)
				defer delete(r.sides)

				area += r.area
				append(&all_sides, ..r.sides)
			}

			sides += {n.side}
		}
	}

	append(&all_sides, PlotSides{pos, FULL_SET - sides})
	return {area + 1, all_sides[:]}
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

package main

import "core:fmt"
import "core:os"
import "core:sort"
import "core:strconv"
import "core:strings"

main :: proc() {
	filename :: "inputs/day2.txt"
	contents, ok := os.read_entire_file(filename)
	if !ok {
		fmt.eprintln("failed to read file:", filename)
		os.exit(1)
	}

	safe_count: int

	str := string(contents)
	for line in strings.split_lines_iterator(&str) {
		line_values, pok := parse_line(line)
		assert(pok)
		defer delete(line_values)

		if process_line(line_values[:]) {
			safe_count += 1
			continue
		}

		for idx in 0 ..< len(line_values) {
			c := make([dynamic]int, len(line_values), context.temp_allocator)
			copy(c[:], line_values[:])
			ordered_remove(&c, idx)

			if process_line(c[:]) {
				safe_count += 1
				break
			}
		}

	}

	fmt.println(safe_count)
}

parse_line :: proc(line: string) -> (values: [dynamic]int, ok: bool) {
	line_parts := strings.split(line, " ", context.temp_allocator)

	values = make([dynamic]int, len(line_parts))
	if !ok {delete(values)}

	for idx := 0; idx < len(line_parts); idx += 1 {
		values[idx] = strconv.parse_int(line_parts[idx]) or_return
	}

	ok = true
	return
}

process_line :: proc(line: []int) -> (ok: bool) {
	direction: enum {
		Undefined,
		Up,
		Down,
	}

	lineit := line

	prev := line[0]
	for curr in line[1:] {
		delta := curr - prev
		prev = curr

		switch direction {
		case .Undefined:
			if delta == 0 {
				// the report is not going in any direction, invalid
				return
			}

			if delta > 0 {
				direction = .Up
			} else {
				direction = .Down
			}
		case .Up:
			if delta <= 0 {
				// changed to down or no change, invalid
				return
			}
		case .Down:
			if delta >= 0 {
				// changed to up or no change, invalid
				return
			}
		}

		if abs(delta) > 3 {
			// change is too big, invalid
			return
		}
	}

	// the report is valid
	ok = true
	return
}

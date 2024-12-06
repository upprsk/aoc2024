package main

import "core:fmt"
import "core:mem"
import "core:os"
import "core:slice"
import "core:sort"
import "core:strconv"
import "core:strings"

main :: proc() {
	filename :: "inputs/day5.txt"
	contents, ok := os.read_entire_file(filename)
	if !ok {
		fmt.eprintln("failed to read file:", filename)
		os.exit(1)
	}

	defer delete(contents)

	mappings := [dynamic]Mapping{}
	defer delete(mappings)

	str := string(contents)
	for line in strings.split_lines_iterator(&str) {
		if line == "" {
			// end of page ordering rules
			break
		}

		m, ok := parse_mapping(line)
		assert(ok)

		append(&mappings, m)
	}

	slice.sort_by(mappings[:], proc(lhs, rhs: Mapping) -> bool {
		return lhs.before < rhs.before
	})

	sum: int

	for line in strings.split_lines_iterator(&str) {
		if line == "" {
			// ignore empty lines
			continue
		}

		middle, ok := line_is_in_order(mappings[:], line)
		if ok {
			sum += middle
		}
	}


	fmt.println(sum)
}

Mapping :: struct {
	before: int,
	after:  int,
}

parse_mapping :: proc(line: string) -> (m: Mapping, ok: bool) {
	lineit := line
	beforestr, _ := strings.split_iterator(&lineit, "|")
	afterstr, _ := strings.split_iterator(&lineit, "|")

	before := strconv.parse_int(beforestr) or_return
	after := strconv.parse_int(afterstr) or_return

	return Mapping{before, after}, true
}

line_is_in_order :: proc(mappings: []Mapping, line: string) -> (middle: int, ok: bool) {
	updates_str := strings.split(line, ",", context.temp_allocator)
	updates := make([]int, len(updates_str), context.temp_allocator)
	for s, idx in updates_str {
		updates[idx] = strconv.parse_int(s) or_return
	}

	was_in_order := true

	// this is the worst sort in history :)
	outer: for {
		for u, i in updates {
			for b, j in updates {
				if j == i do continue

				if should_be_before(mappings, u, b) {
					if i > j {
						// should be before, but found after
						was_in_order = false

						// fix the ordering and re-start
						updates[i], updates[j] = updates[j], updates[i]

						continue outer
					}
				}
			}
		}

		break
	}

	center_idx := len(updates) / 2
	middle = updates[center_idx]
	ok = !was_in_order

	return
}

should_be_before :: proc(mappings: []Mapping, u, b: int) -> bool {
	for m in mappings {
		if m.before > u do break

		if m.before == u && m.after == b do return true
	}

	return false
}

package main

import "core:fmt"
import "core:mem"
import "core:os"
import "core:slice"
import "core:sort"
import "core:strconv"
import "core:strings"

main :: proc() {
	filename :: "inputs/day4.txt"
	contents, ok := os.read_entire_file(filename)
	if !ok {
		fmt.eprintln("failed to read file:", filename)
		os.exit(1)
	}

	defer delete(contents)

	raw_lines := strings.split_lines(string(contents), context.temp_allocator)
	lines := slice.filter(raw_lines, proc(line: string) -> bool {return line != ""})
	defer delete(lines)

	found: int

	m, n := len(lines), len(lines[0])

	for y in 0 ..< m - 2 {
		for x in 0 ..< n - 2 {
			// M.M
			// .A.
			// S.S
			if lines[y + 0][x + 0] == 'M' &&
			   lines[y + 0][x + 2] == 'M' &&
			   lines[y + 1][x + 1] == 'A' &&
			   lines[y + 2][x + 0] == 'S' &&
			   lines[y + 2][x + 2] == 'S' {
				found += 1
			}

			// S.M
			// .A.
			// S.M
			if lines[y + 0][x + 0] == 'S' &&
			   lines[y + 0][x + 2] == 'M' &&
			   lines[y + 1][x + 1] == 'A' &&
			   lines[y + 2][x + 0] == 'S' &&
			   lines[y + 2][x + 2] == 'M' {
				found += 1
			}

			// S.S
			// .A.
			// M.M
			if lines[y + 0][x + 0] == 'S' &&
			   lines[y + 0][x + 2] == 'S' &&
			   lines[y + 1][x + 1] == 'A' &&
			   lines[y + 2][x + 0] == 'M' &&
			   lines[y + 2][x + 2] == 'M' {
				found += 1
			}

			// M.S
			// .A.
			// M.S
			if lines[y + 0][x + 0] == 'M' &&
			   lines[y + 0][x + 2] == 'S' &&
			   lines[y + 1][x + 1] == 'A' &&
			   lines[y + 2][x + 0] == 'M' &&
			   lines[y + 2][x + 2] == 'S' {
				found += 1
			}
		}
	}

	fmt.println(found)
}

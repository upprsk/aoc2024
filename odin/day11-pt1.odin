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

	filename :: "inputs/day11.txt"
	contents, ok := os.read_entire_file(filename)
	if !ok {
		fmt.eprintln("failed to read file:", filename)
		os.exit(1)
	}

	defer delete(contents)

	stones_str := bytes.split(contents, []u8{' '}, context.temp_allocator)
	stones := make([]int, len(stones_str))
	defer delete(stones)

	for s, idx in stones_str {
		ss := strings.trim_space(string(s))
		if len(ss) == 0 do continue

		ok: bool
		stones[idx], ok = strconv.parse_int(string(ss))
		assert(ok)
	}

	blinks :: 25
	for _ in 0 ..< blinks {
		new_stones := make([dynamic]int, 0, len(stones))

		for stone in stones {
			if stone == 0 {
				append(&new_stones, 1)
				continue
			}

			s := fmt.aprint(stone, allocator = context.temp_allocator)
			if len(s) & 1 == 0 {
				// even
				first_str, second_str := s[:len(s) / 2], s[len(s) / 2:]

				ok: bool
				first: int
				second: int

				first, ok = strconv.parse_int(first_str)
				assert(ok)

				second, ok = strconv.parse_int(second_str)
				assert(ok)

				append(&new_stones, first, second)
				continue
			}

			// odd
			append(&new_stones, stone * 2024)
		}
		
		delete(stones)
		stones = new_stones[:]
	}

	fmt.println(len(stones))
}

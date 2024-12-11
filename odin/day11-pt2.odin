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
	stones := make(map[int]int)
	defer delete(stones)

	for s in stones_str {
		ss := strings.trim_space(string(s))
		if len(ss) == 0 do continue

		stone, ok := strconv.parse_int(string(ss))
		assert(ok)

		stones[stone] += 1
	}

	new_stones := make(map[int]int)
	defer delete(new_stones)

	blinks :: 75
	for blink in 0 ..< blinks {
		fmt.println("blink:", blink + 1)

		clear(&new_stones)

		for stone, count in stones {
			if stone == 0 {
				new_stones[1] += count
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

				new_stones[first] += count
				new_stones[second] += count
				continue
			}

			// odd
			value := stone * 2024
			new_stones[value] += count
		}

		free_all(context.temp_allocator)

		stones, new_stones = new_stones, stones
	}

	// if blinks & 1 != 0 {
	// 	stones, new_stones = new_stones, stones
	// }

	total: int
	for stone, count in stones {
		total += count
	}

	fmt.println(total)
}

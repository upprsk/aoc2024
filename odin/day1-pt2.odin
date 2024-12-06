package main

import "core:fmt"
import "core:os"
import "core:sort"
import "core:strconv"
import "core:strings"

main :: proc() {
	filename :: "inputs/day1.txt"
	contents, ok := os.read_entire_file(filename)
	if !ok {
		fmt.eprintln("failed to read file:", filename)
		os.exit(1)
	}

	left, right, pok := parse_data(string(contents))
	assert(pok)
	defer {
		delete(left)
		delete(right)
	}

	sum: int
	for item in left {
		sum += item * right[item]
	}

	fmt.println(sum)
}

parse_data :: proc(contents: string) -> (left: []int, right: map[int]int, ok: bool) {
	left_list := [dynamic]int{}
	defer if !ok {delete(left_list)}
	right = make(map[int]int)
	defer if !ok {delete(right)}

	str := contents
	for line in strings.split_lines_iterator(&str) {
		lhs, rhs := parse_line(line) or_return

		append(&left_list, lhs)
		right[rhs] += 1
	}


	left = left_list[:]
	ok = true
	return
}

parse_line :: proc(line: string) -> (lhs: int, rhs: int, ok: bool) {
	parts := strings.split_n(line, "   ", 2, context.temp_allocator)

	lhs = strconv.parse_int(parts[0]) or_return
	rhs = strconv.parse_int(parts[1]) or_return
	ok = true
	return
}

package main

import "core:fmt"
import "core:mem"
import "core:os"
import "core:slice"
import "core:sort"
import "core:strconv"
import "core:strings"

main :: proc() {
	filename :: "inputs/day3.txt"
	contents, ok := os.read_entire_file(filename)
	if !ok {
		fmt.eprintln("failed to read file:", filename)
		os.exit(1)
	}

	matcher := Matcher {
		input   = string(contents),
		enabled = true,
	}

	total := check(&matcher)

	fmt.println(total)
}

Matcher :: struct {
	input:   string,
	enabled: bool,
}

check :: proc(m: ^Matcher) -> int {
	sum: int

	for len(m.input) != 0 {
		num, ok := check_one(m)
		if ok {sum += num}
	}

	return sum
}

check_one :: proc(m: ^Matcher) -> (result: int, ok: bool) {
	if match(m, 'd') {
		match(m, 'o') or_return
		if match(m, '(') {
			match(m, ')') or_return

			m.enabled = true
			return
		}

		match(m, 'n') or_return
		match(m, '\'') or_return
		match(m, 't') or_return
		match(m, '(') or_return
		match(m, ')') or_return

		m.enabled = false
		return
	}

	match_eager(m, 'm') or_return
	match(m, 'u') or_return
	match(m, 'l') or_return
	match(m, '(') or_return

	as := match_digits(m)
	a := strconv.parse_int(as) or_return

	match(m, ',') or_return

	bs := match_digits(m)
	b := strconv.parse_int(bs) or_return

	match(m, ')') or_return

	result = a * b
	ok = m.enabled
	return
}

match_eager :: proc(m: ^Matcher, c: u8) -> bool {
	if len(m.input) == 0 {
		return false
	}

	// move one character forward
	cc := m.input[0]
	advance(m)

	return cc == c
}

match :: proc(m: ^Matcher, c: u8) -> bool {
	if len(m.input) == 0 || m.input[0] != c {
		return false
	}


	// move one character forward
	advance(m)
	return true
}

match_digits :: proc(m: ^Matcher) -> string {
	start := m.input
	for match_digit(m) {}

	delta := uintptr(raw_data(m.input)) - uintptr(raw_data(start))
	return start[:delta]
}

match_digit :: proc(m: ^Matcher) -> bool {
	if len(m.input) == 0 || !is_digit(m.input[0]) {
		return false
	}

	// move one character forward
	advance(m)
	return true
}

advance :: proc(m: ^Matcher) {
	m.input = m.input[1:]
}

is_digit :: proc(c: u8) -> bool {
	switch c {
	case '0' ..= '9':
		return true
	case:
		return false
	}
}

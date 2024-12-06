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
		input = string(contents),
	}

	total := check(&matcher)

	fmt.println(total)
}

MatcherStates :: enum {
	M,
	U,
	L,
	Lparen,
	First,
	Comma,
	Second,
	Rparen,
	Done,
}

Matcher :: struct {
	state: MatcherStates,
	input: string,
}

check :: proc(m: ^Matcher) -> int {
	sum: int
	first: int
	second: int

	for {
		if num, ok := advance_one(m); ok {
			// got the end of the first number
			#partial switch m.state {
			case .Comma:
				first = num
			case .Rparen:
				second = num
			case .Done:
				sum += first * second
				reset(m)
			}
		}

		if len(m.input) == 0 {
			break
		}
	}

	return sum
}

advance_one :: proc(m: ^Matcher) -> (int, bool) {
	switch m.state {
	case .M:
		match_to_next(m, 'm')
	case .U:
		match_to_next(m, 'u')
	case .L:
		match_to_next(m, 'l')
	case .Comma:
		match_to_next(m, ',')
	case .Lparen:
		match_to_next(m, '(')
	case .Rparen:
		match_to_next(m, ')')
		return 0, true
	case .First:
		start := m.input
		for non_eager_match_digit(m) {}

		delta := uintptr(raw_data(m.input)) - uintptr(raw_data(start))
		num := start[:delta]
		first, ok := strconv.parse_int(num)
		assert(ok)

		m.state = .Comma
		return first, true
	case .Second:
		start := m.input
		for non_eager_match_digit(m) {}

		delta := uintptr(raw_data(m.input)) - uintptr(raw_data(start))
		num := start[:delta]
		first, ok := strconv.parse_int(num)
		assert(ok)

		m.state = .Rparen
		return first, true
	case .Done:
		reset(m)
	}

	return 0, false
}

match_to_next :: proc(m: ^Matcher, c: u8) -> bool {
	match(m, c) or_return
	m.state = MatcherStates(int(m.state) + 1)

	return true
}

match :: proc(m: ^Matcher, c: u8) -> bool {
	if len(m.input) == 0 {
		return false
	}

	// move one character forward
	defer m.input = m.input[1:]

	if m.input[0] == c {
		return true
	}

	reset(m)
	return false
}

non_eager_match_digit :: proc(m: ^Matcher) -> bool {
	if len(m.input) == 0 {
		return false
	}


	if is_digit(m.input[0]) {
		// move one character forward only if we match
		m.input = m.input[1:]
		return true
	}

	reset(m)
	return false
}

reset :: proc(m: ^Matcher) {
	m.state = .M
}

is_digit :: proc(c: u8) -> bool {
	switch c {
	case '0' ..= '9':
		return true
	case:
		return false
	}
}

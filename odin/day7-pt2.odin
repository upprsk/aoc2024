package main

import "core:fmt"
import "core:mem"
import "core:os"
import "core:slice"
import "core:sort"
import "core:strconv"
import "core:strings"

main :: proc() {
	filename :: "inputs/day7.txt"
	contents, ok := os.read_entire_file(filename)
	if !ok {
		fmt.eprintln("failed to read file:", filename)
		os.exit(1)
	}

	defer delete(contents)

	sum: int

	str := string(contents)
	for line in strings.split_lines_iterator(&str) {
		parts := strings.split_n(line, ": ", 2, context.temp_allocator)

		test_value, aok := strconv.parse_int(parts[0])
		assert(aok)

		value_strings := strings.split(parts[1], " ", context.temp_allocator)
		values := make([]int, len(value_strings))
		defer delete(values)

		for vs, idx in value_strings {
			v, vok := strconv.parse_int(vs)
			assert(vok)

			values[idx] = v
		}

		comb := make([]int, len(value_strings) - 1)
		defer delete(comb)

		for operators in number_to_operator_combination(comb, context.temp_allocator) {
			result := eval(values, operators)
			if result == test_value {
				sum += test_value
				break
			}
		}
	}

	fmt.println(sum)
}

Operator :: enum {
	Add,
	Mul,
	Concat,
}

eval :: proc(a: []int, b: []Operator) -> int {
	assert(len(a) == len(b) + 1)

	result := a[0]
	for i in 0 ..< len(b) {
		switch b[i] {
		case .Add:
			result += a[i + 1]
		case .Mul:
			result *= a[i + 1]
		case .Concat:
			decimals: int
			t := a[i + 1]

			for t > 0 {
				t /= 10
				decimals += 1
			}

			for _ in 0 ..< decimals {
				result *= 10
			}

			result += a[i + 1]
		}
	}

	return result
}

number_to_operator_combination :: proc(
	comb: []int,
	allocator := context.allocator,
) -> (
	[]Operator,
	bool,
) {
	if slice.all_of(comb, -1) do return nil, false

	ops := make([]Operator, len(comb), allocator)
	for n, i in comb {
		ops[i] = Operator(n)
	}

	for &n in comb {
		n += 1
		if n <= int(Operator.Concat) {
			break
		} else {
			n = 0
		}
	}

	if slice.all_of(comb, 0) {
		slice.fill(comb, -1)
	}

	return ops, true
}

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

		comb: int
		for operators in number_to_operator_combination(
			len(value_strings) - 1,
			&comb,
			context.temp_allocator,
		) {
			result := eval(values, operators)
			// fmt.println(values, operators, "=", result)

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
		}
	}

	return result
}

number_to_operator_combination :: proc(
	count: int,
	comb: ^int,
	allocator := context.allocator,
) -> (
	[]Operator,
	bool,
) {
	// in case we have cycled all combinations up to count, then we are done.
	if comb^ == 1 << uint(count) {
		return nil, false
	}

	ops := make([]Operator, count)
	for i in 0 ..< count {
		v := (comb^ >> uint(i)) & 1
		if v == 1 {
			ops[i] = .Add
		} else {
			ops[i] = .Mul
		}
	}

	comb^ += 1

	return ops, true
}

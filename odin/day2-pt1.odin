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
		sts, ok := parse_line(line)
		if !ok {
			fmt.eprintln("failed to parse line:", line)
			os.exit(1)
		}

		if sts == .Ok {
			safe_count += 1
		}
	}

	fmt.println(safe_count)
}

ReportStatus :: enum {
	Error,
	Ok,
}

parse_line :: proc(line: string) -> (sts: ReportStatus, ok: bool) {
	direction: enum {
		Undefined,
		Up,
		Down,
	}

	lineit := line

	prev_str := strings.split_iterator(&lineit, " ") or_return
	prev := strconv.parse_int(prev_str) or_return

	for item in strings.split_iterator(&lineit, " ") {
		curr := strconv.parse_int(item) or_return
		delta := curr - prev
		prev = curr

		switch direction {
		case .Undefined:
			if delta == 0 {
				// the report is not going in any direction, invalid
				ok = true
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
				ok = true
				return
			}
		case .Down:
			if delta >= 0 {
				// changed to up or no change, invalid
				ok = true
				return
			}
		}

		if abs(delta) > 3 {
			// change is too big, invalid
			ok = true
			return
		}
	}

	// the report is valid
	sts = .Ok
	ok = true
	return
}

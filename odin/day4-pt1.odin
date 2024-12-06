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

	raw_lines := strings.split_lines(string(contents))
	lines := slice.filter(raw_lines, proc(line: string) -> bool {return line != ""})
	delete(raw_lines)
	defer delete(lines)

	found: int

	m, n := len(lines), len(lines[0])

	// check all lines
	for y in 0 ..< m {
		mf := Matcher {
			pattern = "XMAS",
		}
		mb := Matcher {
			pattern = "SAMX",
		}

		for x in 0 ..< n {
			if match(&mf, lines[y][x]) {
				found += 1
			}
			if match(&mb, lines[y][x]) {
				found += 1
			}
		}
	}

	// check all columns
	for y in 0 ..< m {
		mf := Matcher {
			pattern = "XMAS",
		}
		mb := Matcher {
			pattern = "SAMX",
		}

		for x in 0 ..< n {
			if match(&mf, lines[x][y]) {
				found += 1
			}
			if match(&mb, lines[x][y]) {
				found += 1
			}
		}
	}

	// check forward diagonals
	for j in 0 ..< n {
		mf := Matcher {
			pattern = "XMAS",
		}
		mb := Matcher {
			pattern = "SAMX",
		}

		for x, y := 0, j; x < m && y < n; x, y = x + 1, y + 1 {
			if match(&mf, lines[x][y]) {
				found += 1
			}
			if match(&mb, lines[x][y]) {
				found += 1
			}
		}
	}

	for i in 1 ..< m {
		mf := Matcher {
			pattern = "XMAS",
		}
		mb := Matcher {
			pattern = "SAMX",
		}

		for x, y := i, 0; x < m && y < n; x, y = x + 1, y + 1 {
			if match(&mf, lines[x][y]) {
				found += 1
			}
			if match(&mb, lines[x][y]) {
				found += 1
			}
		}
	}

	// check reverse diagonals
	for j in 0 ..< n {
		mf := Matcher {
			pattern = "XMAS",
		}
		mb := Matcher {
			pattern = "SAMX",
		}

		for x, y := 0, j; x < m && y >= 0; x, y = x + 1, y - 1 {
			if match(&mf, lines[x][y]) {
				found += 1
			}
			if match(&mb, lines[x][y]) {
				found += 1
			}
		}
	}

	for i in 1 ..< m {
		mf := Matcher {
			pattern = "XMAS",
		}
		mb := Matcher {
			pattern = "SAMX",
		}

		for x, y := i, n - 1; x < m && y >= 0; x, y = x + 1, y - 1 {
			if match(&mf, lines[x][y]) {
				found += 1
			}
			if match(&mb, lines[x][y]) {
				found += 1
			}
		}
	}

	fmt.println(found)
}

Matcher :: struct {
	pattern: string,
	idx:     int,
}

match :: proc(m: ^Matcher, c: u8) -> (ok: bool) {
	if c != m.pattern[m.idx] {
		m.idx = 0
	}

	if c == m.pattern[m.idx] {
		m.idx += 1
	}

	if m.idx == len(m.pattern) {
		m.idx = 0
		ok = true
	}

	return
}

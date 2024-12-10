package main

import "core:bytes"
import "core:fmt"
import "core:mem"
import "core:os"
import "core:slice"
import "core:sort"
import "core:strconv"
import "core:strings"

main :: proc() {
	filename :: "inputs/day9.txt"
	contents, ok := os.read_entire_file(filename)
	if !ok {
		fmt.eprintln("failed to read file:", filename)
		os.exit(1)
	}

	defer delete(contents)

	str := string(contents)

	blocks := find_blocks(str)
	defer delete(blocks)

	// visualize_blocks(blocks)
	// fmt.println("---")

	for i, j := 0, len(blocks) - 1; i < j; {
		// find free block
		for i <= j && blocks[i].id >= 0 do i += 1
		if i > j do break

		// find used block
		for j >= i && blocks[j].id < 0 do j -= 1
		if j < i do break

		blocks[i], blocks[j] = blocks[j], blocks[i]
		// visualize_blocks(blocks)
	}

	// visualize_blocks(blocks)

	checksum := calculate_checksum(blocks)
	fmt.println(checksum)
}

Block :: struct {
	id: int,
}

find_blocks :: proc(s: string) -> []Block {
	blocks: [dynamic]Block

	// true means file block (used) and false means free block
	mode := true
	id := 0

	for c in s {
		if c < '0' || c > '9' do break

		size := int(c - '0')
		bid := -1

		if mode {
			bid = id
			id += 1
		}

		for _ in 0 ..< size {
			append(&blocks, Block{bid})
		}

		mode = !mode
	}

	return blocks[:]
}

calculate_checksum :: proc(blocks: []Block) -> (c: int) {
	for b, idx in blocks {
		if b.id >= 0 do c += b.id * idx
	}

	return
}

visualize_blocks :: proc(blocks: []Block) {
	for b in blocks {
		if b.id < 0 {
			fmt.print('.')
		} else {
			fmt.printf("\n%d", b.id)
		}
	}

	fmt.println()
}

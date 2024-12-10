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

	// visualize_blocks(blocks[:])
	// fmt.println("---")

	for j := len(blocks) - 1; j >= 0; j -= 1 {
		// find first free block that fits the block we want to move
		i := 0
		for i < j && (blocks[i].id >= 0 || blocks[i].size < blocks[j].size) do i += 1
		if i >= j do continue
		if blocks[j].id < 0 do continue

		blocks[i].size -= blocks[j].size
		if blocks[i].size == 0 {
			fmt.printfln("swap %d (%v) into %d (%v)", j, blocks[j], i, blocks[i])

			blocks[i] = blocks[j]
			blocks[j].id = -1
		} else {
			fmt.printfln("inject %d (%v) into %d (%v)", j, blocks[j], i, blocks[i])

			blk := blocks[j]
			blocks[j].id = -1

			inject_at(&blocks, i, blk)
		}

		// visualize_blocks(blocks[:])
	}

	// visualize_blocks(blocks[:])

	checksum := calculate_checksum(blocks[:])
	fmt.println(checksum)
}

Block :: struct {
	id:   int,
	size: int,
}

find_blocks :: proc(s: string) -> [dynamic]Block {
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

		append(&blocks, Block{bid, size})
		mode = !mode
	}

	return blocks
}

calculate_checksum :: proc(blocks: []Block) -> (c: int) {
	idx: int
	for b in blocks {
		if b.id >= 0 {
			// fmt.println(b)
			for i in idx ..< idx + b.size {
				// fmt.printfln("%d * %d = %d", i, b.id, b.id * i)
				c += b.id * i
			}
		}

		idx += b.size
	}

	return
}

visualize_blocks :: proc(blocks: []Block) {
	for b in blocks {
		if b.id < 0 {
			for _ in 0 ..< b.size {
				fmt.print('.')
			}
		} else {
			for _ in 0 ..< b.size {
				fmt.printf("%d", b.id)
			}
		}
	}

	fmt.println()
}

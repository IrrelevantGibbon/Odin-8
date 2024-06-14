package chip

import "core:math/rand"
import "core:mem"

Version :: "0.0.1"

ChipType :: enum {
	Chip8,
	SCHIP,
}

CHIP_TYPE :: ChipType.Chip8

when CHIP_TYPE == ChipType.SCHIP {
	SCREEN_WIDTH :: 128
	SCREEN_HEIGHT :: 64
} else {
	SCREEN_WIDTH :: 64
	SCREEN_HEIGHT :: 32
}

Screen :: struct {
	frame:        [SCREEN_WIDTH * SCREEN_HEIGHT]u8,
	frame_buffer: [SCREEN_WIDTH * SCREEN_HEIGHT]u8,
}

Chip8 :: struct {
	cpu:      Cpu,
	keyboard: [16]u8,
	memory:   [4096]u8,
	screen:   Screen,
}


init_chip :: proc() -> ^Chip8 {
	chip := new(Chip8)
	chip^ = Chip8 {
		init_cpu(),
		[16]u8{},
		[4096]u8{},
		Screen{[SCREEN_WIDTH * SCREEN_HEIGHT]u8{}, [SCREEN_WIDTH * SCREEN_HEIGHT]u8{}},
	}

	get_memory := proc() -> ^[4096]u8 {
		return &chip.memory
	}

	get_keys := proc() -> ^[16]u8 {
		return &chip.keys
	}

	get_screen := proc() -> ^Screen {
		return &chip.screen
	}

	chip.cpu.keys = get_keys
	chip.cpu.memory = get_memory
	chip.cpu.screen = get_screen

	return chip
}

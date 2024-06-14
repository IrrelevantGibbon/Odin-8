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

	chip.cpu.keys = &chip.keyboard
	chip.cpu.memory = &chip.memory
	chip.cpu.screen = &chip.screen

	return chip
}

chip_loop :: proc(chip: ^Chip8) {
	get_keyboard_event(&chip.keyboard)
	emulate_cycle(&chip.cpu)
	draw_on_screen(&chip.screen)
}

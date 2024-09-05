package chip

import "core:fmt"
import "core:log"
import "core:mem"
import "core:os"
import rl "vendor:raylib"

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
	memory:   [MEMORY_SIZE]u8,
	screen:   Screen,
}

Play :: proc(filename: string) {
	chip_8 := InitChip()
	defer free(chip_8)

	file_error := LoadRomIntoMemory(filename, &chip_8.memory)

	if file_error != nil  {
		log.errorf("Error while trying to load file into memory '%s': %v\n", filename, file_error)
		os.exit(1)
	}

	init_window()
	defer shutdown_window()
	for !rl.WindowShouldClose() {
		ChipLoop(chip_8)
	}
}


InitChip :: proc() -> ^Chip8 {
	chip := new(Chip8)
	chip^ = Chip8 {
		InitCpu(),
		[16]u8{},
		[MEMORY_SIZE]u8{},
		Screen{[SCREEN_WIDTH * SCREEN_HEIGHT]u8{}, [SCREEN_WIDTH * SCREEN_HEIGHT]u8{}},
	}

	chip.cpu.keys = &chip.keyboard
	chip.cpu.memory = &chip.memory
	chip.cpu.screen = &chip.screen

	mem.copy(&chip.memory, &font, len(font))
	return chip
}

ChipLoop :: proc(chip: ^Chip8) {
	GetKeyboardEvent(&chip.keyboard)
	EmulateCycle(&chip.cpu)
	draw_on_screen(&chip.screen)
}
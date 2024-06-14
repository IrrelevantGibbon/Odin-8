package chip

import "core:log"
import "core:mem"
import "core:os"

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
	memory:   [MEMORY_SIZE]u8,
	screen:   Screen,
}


init_chip :: proc() -> ^Chip8 {
	chip := new(Chip8)
	chip^ = Chip8 {
		init_cpu(),
		[16]u8{},
		[MEMORY_SIZE]u8{},
		Screen{[SCREEN_WIDTH * SCREEN_HEIGHT]u8{}, [SCREEN_WIDTH * SCREEN_HEIGHT]u8{}},
	}

	chip.cpu.keys = &chip.keyboard
	chip.cpu.memory = &chip.memory
	chip.cpu.screen = &chip.screen

	mem.copy(&chip.memory, &font, len(font))
	load_rom(os.args[1], &chip.memory)
	return chip
}

chip_loop :: proc(chip: ^Chip8) {
	get_keyboard_event(&chip.keyboard)
	emulate_cycle(&chip.cpu)
	draw_on_screen(&chip.screen)
}

load_rom :: proc(file_name: string, memory: ^[MEMORY_SIZE]u8) -> u8 {
	file, err := os.open(file_name, os.O_RDONLY)
	if err != 0 {
		log.error("Failed to open file")
		return 1
	}

	defer os.close(file)

	size, size_err := os.file_size(file)
	if size_err != 0 {
		log.error("Failed to get file size")
		return 1
	}

	if size > len(memory) - OFFSET_START_PROGRAM {
		log.error("File size exceeds memory capacity")
		return 1
	}

	read_bytes, _ := os.read_ptr(file, mem.ptr_offset(memory + OFFSET_START_PROGRAM), int(size))
	if read_bytes != int(size) {
		log.error("Error reading file")
		return 1
	}

	return 0
}

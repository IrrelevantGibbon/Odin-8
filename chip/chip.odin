package chip

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

Chip8 :: struct {
	cpu:      Cpu,
	keyboard: [16]u8,
	memory:   [SCREEN_WIDTH * SCREEN_HEIGHT]u8,
}

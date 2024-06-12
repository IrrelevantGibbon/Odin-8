package chip

CYCLE_PER_FRAME :: 12

Cpu :: struct {
	v_register:      [16]u8,
	idx_register:    u8,
	delay_timer:     u8,
	sound_timer:     u8,
	program_counter: u16,
	stack_pointer:   u8,
	stack:           [16]u8,
}

Nibble :: struct {
	opcode: u16,
	x:      u8,
	y:      u8,
	n:      u8,
	nn:     u8,
	nnn:    u16,
}


fetch :: proc() {

}

decode :: proc() {

}

execute :: proc() {

}

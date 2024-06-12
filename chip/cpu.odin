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

dec_x :: #force_inline proc(opcode: u16) -> u8 {
	return u8((opcode & 0x0F00) >> 8)
}

dec_y :: #force_inline proc(opcode: u16) -> u8 {
	return u8((opcode & 0x00F0) >> 4)
}

dec_n :: #force_inline proc(opcode: u16) -> u8 {
	return u8(opcode & 0x000F)
}

dec_nn :: #force_inline proc(opcode: u16) -> u8 {
	return u8(opcode & 0x00FF)
}

dec_nnn :: #force_inline proc(opcode: u16) -> u16 {
	return opcode & 0x0FFF
}

emulate_cycle :: proc(cpu: ^Cpu, memory: ^[4096]u8) {
	opcode := fetch(cpu, memory)
	nibble := decode(opcode)
	execute(cpu, memory, nibble)
}

fetch :: proc(cpu: ^Cpu, memory: ^[4096]u8) -> u16 {
	opcode := u16(memory[cpu.program_counter]) << 8 | u16(memory[cpu.program_counter + 1])
	cpu.program_counter += 2
	return opcode
}

decode :: proc(opcode: u16) -> Nibble {
	return(
		Nibble {
			opcode,
			dec_x(opcode),
			dec_y(opcode),
			dec_n(opcode),
			dec_nn(opcode),
			dec_nnn(opcode),
		} \
	)
}

execute :: proc(cpu: ^Cpu, memory: ^[4096]u8, nibble: Nibble) {

}

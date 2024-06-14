package chip

import "core:fmt"
import "core:log"
import str "core:strings"
import rl "vendor:raylib"

CYCLE_PER_FRAME :: 12

Cpu :: struct {
	v_register:      [16]u8,
	idx_register:    u16,
	delay_timer:     u8,
	sound_timer:     u8,
	program_counter: u16,
	stack_pointer:   u8,
	stack:           [16]u16,
	rpl_flag:        [8]u8,
	memory:          ^[MEMORY_SIZE]u8,
	screen:          ^Screen,
	keys:            ^[16]u8,
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

init_cpu :: proc() -> Cpu {
	return Cpu{[16]u8{}, 0, 0, 0, OFFSET_START_PROGRAM, 0, [16]u16{}, [8]u8{}, nil, nil, nil}
}

decrement_timers :: proc(cpu: ^Cpu) {
	if cpu.delay_timer > 0 {
		cpu.delay_timer -= 1
	}

	if cpu.sound_timer > 0 {
		cpu.sound_timer -= 1
	}
}

emulate_cycles_per_frame :: proc(cpu: ^Cpu) {
	for i in 0 ..< CYCLE_PER_FRAME {
		emulate_cycle(cpu)
	}
}

emulate_cycle :: proc(cpu: ^Cpu) {
	opcode := fetch(cpu)
	nibble := decode(opcode)
	execute(cpu, nibble)
}

fetch :: proc(cpu: ^Cpu) -> u16 {
	opcode := u16(cpu.memory[cpu.program_counter]) << 8 | u16(cpu.memory[cpu.program_counter + 1])
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

execute :: proc(cpu: ^Cpu, nibble: Nibble) {
	log.info("Executing opcode: 0x%X\n", nibble.opcode)

	op := nibble.opcode

	switch op & 0xF000 {
	case 0x0000:
		switch op & 0x000F {
		case 0x0000:
			CLS(cpu)
			log.info("CLS() called\n")
		case 0x000E:
			RET(cpu)
			log.info("RET() called\n")
		}
	case 0x1000:
		JP(cpu, nibble.nnn)
		log.info("JP(%u) called\n", nibble.nnn)
	case 0x2000:
		CALL(cpu, nibble.nnn)
		log.info("CALL(%u) called\n", nibble.nnn)
	case 0x3000:
		SE(cpu, nibble.x, nibble.nn)
		log.info("SE(%u, %u) called\n", nibble.x, nibble.nn)
	case 0x4000:
		SNE(cpu, nibble.x, nibble.nn)
		log.info("SNE(%u, %u) called\n", nibble.x, nibble.nn)
	case 0x5000:
		SE_REG(cpu, nibble.x, nibble.y)
		log.info("SE_REG(%u, %u) called\n", nibble.x, nibble.y)
	case 0x6000:
		LD(cpu, nibble.x, nibble.nn)
		log.info("LD(%u, %u) called\n", nibble.x, nibble.nn)
	case 0x7000:
		ADD(cpu, nibble.x, nibble.nn)
		log.info("ADD(%u, %u) called\n", nibble.x, nibble.nn)
	case 0x8000:
		switch op & 0x000F {
		case 0x0000:
			LD_REG(cpu, nibble.x, nibble.y)
			log.info("LD_REG(%u, %u) called\n", nibble.x, nibble.y)
		case 0x0001:
			OR(cpu, nibble.x, nibble.y)
			log.info("OR(%u, %u) called\n", nibble.x, nibble.y)
		case 0x0002:
			AND(cpu, nibble.x, nibble.y)
			log.info("AND(%u, %u) called\n", nibble.x, nibble.y)
		case 0x0003:
			XOR(cpu, nibble.x, nibble.y)
			log.info("XOR(%u, %u) called\n", nibble.x, nibble.y)
		case 0x0004:
			ADD_REG(cpu, nibble.x, nibble.y)
			log.info("ADD_REG(%u, %u) called\n", nibble.x, nibble.y)
		case 0x0005:
			SUB(cpu, nibble.x, nibble.y)
			log.info("SUB(%u, %u) called\n", nibble.x, nibble.y)
		case 0x0006:
			SHR(cpu, nibble.x)
			log.info("SHR(%u) called\n", nibble.x)
		case 0x0007:
			SUBN(cpu, nibble.x, nibble.y)
			log.info("SUBN(%u, %u) called\n", nibble.x, nibble.y)
		case 0x000E:
			SHL(cpu, nibble.x)
			log.info("SHL(%u) called\n", nibble.x)
			default: {log.info("Unknown opcode in 0x8000 switch: 0x%X\n", nibble.opcode)}
		}
	case 0x9000:
		SNE_REG(cpu, nibble.x, nibble.y)
		log.info("SNE_REG(%u, %u) called\n", nibble.x, nibble.y)
	case 0xA000:
		LD_I(cpu, nibble.nnn)
		log.info("LD_I(%u) called\n", nibble.nnn)
	case 0xB000:
		JP_V0(cpu, nibble.nnn)
		log.info("JP_V0(%u) called\n", nibble.nnn)
	case 0xC000:
		RND(cpu, nibble.x, nibble.nn)
		log.info("RND(%u, %u) called\n", nibble.x, nibble.nn)
	case 0xD000:
		DRW(cpu, nibble.x, nibble.y, nibble.n)
		log.info("DRW(%u, %u, %u) called\n", nibble.x, nibble.y, nibble.n)
	case 0xE000:
		switch op & 0x00FF {
		case 0x009E:
			SKP(cpu, nibble.x)
			log.info("SKP(%u) called\n", nibble.x)
		case 0x00A1:
			SKNP(cpu, nibble.x)
			log.info("SKNP(%u) called\n", nibble.x)
		case:
			log.info("Unknown opcode in 0xE000 switch: 0x%X\n", op)
		}
	case 0xF000:
		switch op & 0x00FF {
		case 0x0007:
			LD_REG_DT(cpu, nibble.x)
			log.info("LD_REG_DT(%u) called, Opcode: 0x%X\n", nibble.x, op)
		case 0x000A:
			LD_KEY(cpu, nibble.x)
			log.info("LD_KEY(%u) called, Opcode: 0x%X\n", nibble.x, op)
		case 0x0015:
			LD_DT(cpu, nibble.x)
			log.info("LD_DT(%u) called, Opcode: 0x%X\n", nibble.x, op)
		case 0x0018:
			LD_ST(cpu, nibble.x)
			log.info("LD_ST(%u) called, Opcode: 0x%X\n", nibble.x, op)
		case 0x001E:
			ADD_I(cpu, nibble.x)
			log.info("ADD_I(%u) called, Opcode: 0x%X\n", nibble.x, op)
		case 0x0029:
			LD_F(cpu, nibble.x)
			log.info("LD_F(%u) called, Opcode: 0x%X\n", nibble.x, op)
		case 0x0030:
			LD_FE(cpu, nibble.x)
			log.info("LD_FE(%u) called, Opcode: 0x%X\n", nibble.x, op)
		case 0x0033:
			LD_B(cpu, nibble.x)
			log.info("LD_B(%u) called, Opcode: 0x%X\n", nibble.x, op)
		case 0x0055:
			LD_MEM(cpu, nibble.x)
			log.info("LD_MEM(%u) called, Opcode: 0x%X\n", nibble.x, op)
		case 0x0065:
			LD_REG_MEM(cpu, nibble.x)
			log.info("LD_REG_MEM(%u) called, Opcode: 0x%X\n", nibble.x, op)
		case 0x0075:
			STR_RPL(cpu, nibble.x)
			log.info("STR_RPL(%u) called, Opcode: 0x%X\n", nibble.x, op)
		case 0x0085:
			LD_RPL(cpu, nibble.x)
			log.info("LD_RPL(%u) called, Opcode: 0x%X\n", nibble.x, op)
		case:
			log.info("Unknown opcode in 0xF000 switch: 0x%X\n", op)
		}
	case:
		log.info("Unknown main switch opcode: 0x%X\n", op)
	}
	decrement_timers(cpu)
}

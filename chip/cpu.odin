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

DecX :: #force_inline proc(opcode: u16) -> u8 {
	return u8((opcode & 0x0F00) >> 8)
}

DecY :: #force_inline proc(opcode: u16) -> u8 {
	return u8((opcode & 0x00F0) >> 4)
}

DecN :: #force_inline proc(opcode: u16) -> u8 {
	return u8(opcode & 0x000F)
}

DecNN :: #force_inline proc(opcode: u16) -> u8 {
	return u8(opcode & 0x00FF)
}

DecNNN :: #force_inline proc(opcode: u16) -> u16 {
	return opcode & 0x0FFF
}

InitCpu :: proc() -> Cpu {
	return Cpu{[16]u8{}, 0, 0, 0, OFFSET_START_PROGRAM, 0, [16]u16{}, [8]u8{}, nil, nil, nil}
}

DecrementTimers :: proc(cpu: ^Cpu) {
	if cpu.delay_timer > 0 {
		cpu.delay_timer -= 1
	}

	if cpu.sound_timer > 0 {
		cpu.sound_timer -= 1
	}
}

EmulateCyclesPerFrame :: proc(cpu: ^Cpu) {
	for i in 0 ..< CYCLE_PER_FRAME {
		EmulateCycle(cpu)
	}
}

EmulateCycle :: proc(cpu: ^Cpu) {
	opcode := Fetch(cpu)
	nibble := Decode(opcode)
	Execute(cpu, nibble)
}

Fetch :: proc(cpu: ^Cpu) -> u16 {
	opcode := u16(cpu.memory[cpu.program_counter]) << 8 | u16(cpu.memory[cpu.program_counter + 1])
	cpu.program_counter += 2
	return opcode
}

Decode :: proc(opcode: u16) -> Nibble {
	return(
		Nibble {
			opcode,
			DecX(opcode),
			DecY(opcode),
			DecN(opcode),
			DecNN(opcode),
			DecNNN(opcode),
		} \
	)
}

Execute :: proc(cpu: ^Cpu, nibble: Nibble) {
	op := nibble.opcode
	switch op & 0xF000 {
	case 0x0000:
		switch op & 0x000F {
		case 0x0000:
			CLS(cpu)
		case 0x000E:
			RET(cpu)
		}
	case 0x1000:
		JP(cpu, nibble.nnn)
	case 0x2000:
		CALL(cpu, nibble.nnn)
	case 0x3000:
		SE(cpu, nibble.x, nibble.nn)
	case 0x4000:
		SNE(cpu, nibble.x, nibble.nn)
	case 0x5000:
		SE_REG(cpu, nibble.x, nibble.y)
	case 0x6000:
		LD(cpu, nibble.x, nibble.nn)
	case 0x7000:
		ADD(cpu, nibble.x, nibble.nn)
	case 0x8000:
		switch op & 0x000F {
		case 0x0000:
			LD_REG(cpu, nibble.x, nibble.y)
		case 0x0001:
			OR(cpu, nibble.x, nibble.y)
		case 0x0002:
			AND(cpu, nibble.x, nibble.y)
		case 0x0003:
			XOR(cpu, nibble.x, nibble.y)
		case 0x0004:
			ADD_REG(cpu, nibble.x, nibble.y)
		case 0x0005:
			SUB(cpu, nibble.x, nibble.y)
		case 0x0006:
			SHR(cpu, nibble.x)
		case 0x0007:
			SUBN(cpu, nibble.x, nibble.y)
		case 0x000E:
			SHL(cpu, nibble.x)
			default: {log.info("Unknown opcode in 0x8000 switch: 0x%X\n", nibble.opcode)}
		}
	case 0x9000:
		SNE_REG(cpu, nibble.x, nibble.y)
	case 0xA000:
		LD_I(cpu, nibble.nnn)
	case 0xB000:
		JP_V0(cpu, nibble.nnn)
	case 0xC000:
		RND(cpu, nibble.x, nibble.nn)
	case 0xD000:
		DRW(cpu, nibble.x, nibble.y, nibble.n)
	case 0xE000:
		switch op & 0x00FF {
		case 0x009E:
			SKP(cpu, nibble.x)
		case 0x00A1:
			SKNP(cpu, nibble.x)
		case:
			log.info("Unknown opcode in 0xE000 switch: 0x%X\n", op)
		}
	case 0xF000:
		switch op & 0x00FF {
		case 0x0007:
			LD_REG_DT(cpu, nibble.x)
		case 0x000A:
			LD_KEY(cpu, nibble.x)
		case 0x0015:
			LD_DT(cpu, nibble.x)
		case 0x0018:
			LD_ST(cpu, nibble.x)
		case 0x001E:
			ADD_I(cpu, nibble.x)
		case 0x0029:
			LD_F(cpu, nibble.x)
		case 0x0030:
			LD_FE(cpu, nibble.x)
		case 0x0033:
			LD_B(cpu, nibble.x)
		case 0x0055:
			LD_MEM(cpu, nibble.x)
		case 0x0065:
			LD_REG_MEM(cpu, nibble.x)
		case 0x0075:
			STR_RPL(cpu, nibble.x)
		case 0x0085:
			LD_RPL(cpu, nibble.x)
		case:
			log.info("Unknown opcode in 0xF000 switch: 0x%X\n", op)
		}
	case:
		log.info("Unknown main switch opcode: 0x%X\n", op)
	}
	DecrementTimers(cpu)
}

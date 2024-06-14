package chip


import "core:fmt"
import "core:math/rand"
import "core:mem"

CLS :: #force_inline proc(cpu: ^Cpu) {
	for i in 0 ..< (SCREEN_WIDTH * SCREEN_HEIGHT) {
		cpu.screen.frame[i] = 0
	}
}

JP :: #force_inline proc(cpu: ^Cpu, nnn: u16) {
	cpu.program_counter = nnn
}

RET :: #force_inline proc(cpu: ^Cpu) {
	cpu.stack_pointer -= 1
	cpu.program_counter = cpu.stack[cpu.stack_pointer]
}

CALL :: #force_inline proc(cpu: ^Cpu, nnn: u16) {
	cpu.stack[cpu.stack_pointer] = cpu.program_counter
	cpu.stack_pointer += 1
	cpu.program_counter = nnn
}

SE :: #force_inline proc(cpu: ^Cpu, x: u8, nn: u8) {
	if cpu.v_register[x] == nn {
		cpu.program_counter += 2
	}
}

SNE :: #force_inline proc(cpu: ^Cpu, x: u8, nn: u8) {
	if cpu.v_register[x] != nn {
		cpu.program_counter += 2
	}
}

SE_REG :: #force_inline proc(cpu: ^Cpu, x: u8, y: u8) {
	if cpu.v_register[x] == cpu.v_register[y] {
		cpu.program_counter += 2
	}
}

LD :: #force_inline proc(cpu: ^Cpu, x: u8, nn: u8) {
	cpu.v_register[x] = nn
}

ADD :: #force_inline proc(cpu: ^Cpu, x: u8, nn: u8) {
	cpu.v_register[x] += nn
}

LD_REG :: #force_inline proc(cpu: ^Cpu, x: u8, y: u8) {
	cpu.v_register[x] = cpu.v_register[y]
}

OR :: #force_inline proc(cpu: ^Cpu, x: u8, y: u8) {
	cpu.v_register[x] |= cpu.v_register[y]
}

AND :: #force_inline proc(cpu: ^Cpu, x: u8, y: u8) {
	cpu.v_register[x] &= cpu.v_register[y]
}

XOR :: #force_inline proc(cpu: ^Cpu, x: u8, y: u8) {
	cpu.v_register[x] = cpu.v_register[y]
}

ADD_REG :: #force_inline proc(cpu: ^Cpu, x: u8, y: u8) {
	cpu.v_register[x] += cpu.v_register[y]
	cpu.v_register[0xF] = 0
	if cpu.v_register[y] > 0xFF - cpu.v_register[x] {
		cpu.v_register[0xF] = 1
	}
}

SUB :: #force_inline proc(cpu: ^Cpu, x: u8, y: u8) {
	cpu.v_register[0xF] = 0
	if cpu.v_register[x] > cpu.v_register[y] {
		cpu.v_register[0xF] = 1
	}
	cpu.v_register[x] -= cpu.v_register[y]
}

SHR :: #force_inline proc(cpu: ^Cpu, x: u8) {
	cpu.v_register[0xF] = 0
	if (cpu.v_register[x] & 0x01) == 1 {
		cpu.v_register[0xF] = 1
	}
	cpu.v_register[x] /= 2
}

SUBN :: #force_inline proc(cpu: ^Cpu, x: u8, y: u8) {
	cpu.v_register[0xF] = 0
	if cpu.v_register[x] < cpu.v_register[y] {
		cpu.v_register[0xF] = 1
	}
	cpu.v_register[x] = cpu.v_register[y] - cpu.v_register[x]
}

SHL :: #force_inline proc(cpu: ^Cpu, x: u8) {
	cpu.v_register[0xF] = 0
	if ((cpu.v_register[x] >> 7) & 0x01) == 1 {
		cpu.v_register[0xF] = 1
	}
	cpu.v_register[x] *= 2
}

SNE_REG :: #force_inline proc(cpu: ^Cpu, x: u8, y: u8) {
	if cpu.v_register[x] != cpu.v_register[y] {
		cpu.program_counter += 2
	}
}

LD_I :: #force_inline proc(cpu: ^Cpu, nnn: u16) {
	cpu.idx_register = nnn
}

JP_V0 :: #force_inline proc(cpu: ^Cpu, nnn: u16) {
	cpu.program_counter = u16(cpu.v_register[0]) + nnn
}

RND :: #force_inline proc(cpu: ^Cpu, x: u8, nn: u8) {
	cpu.v_register[x] = u8(u8(rand.int_max(255) % 256) & nn)
}

DRW :: #force_inline proc(cpu: ^Cpu, x: u8, y: u8, n: u8) {
	cpu.v_register[0xF] = 0
	vx := u16(cpu.v_register[x])
	vy := u16(cpu.v_register[y])
	heigh := n
	width := 8

	if n == 0 && CHIP_TYPE == ChipType.SCHIP {
		heigh = 16
		width = 16
	}

	for i in 0 ..< heigh {
		pxl := cpu.memory[cpu.idx_register + u16(i)]
		for j in 0 ..< width {
			if (pxl & (0x80 >> u32(j))) != 0 {
				screenPxl := &cpu.screen.frame[(vy + u16(i)) * SCREEN_WIDTH + vx + u16(j)]
				if screenPxl^ == 1 {
					cpu.v_register[0xF] = 1
				}
				screenPxl^ = 1
			}
		}
	}
}

SKP :: #force_inline proc(cpu: ^Cpu, x: u8) {
	if cpu.keys[cpu.v_register[x]] == 1 {
		cpu.program_counter += 2
	}
}

SKNP :: #force_inline proc(cpu: ^Cpu, x: u8) {
	if cpu.keys[cpu.v_register[x]] == 0 {
		cpu.program_counter += 2
	}
}

LD_REG_DT :: #force_inline proc(cpu: ^Cpu, x: u8) {
	cpu.v_register[x] = cpu.delay_timer
}

LD_KEY :: #force_inline proc(cpu: ^Cpu, x: u8) {
	for i in 0 ..< 16 {
		if cpu.keys[i] == 1 {
			cpu.v_register[x] = u8(i)
			return
		}
	}
	cpu.program_counter -= 2
}

LD_DT :: #force_inline proc(cpu: ^Cpu, x: u8) {
	cpu.delay_timer = cpu.v_register[x]
}

LD_ST :: #force_inline proc(cpu: ^Cpu, x: u8) {
	cpu.sound_timer = cpu.v_register[x]
}

ADD_I :: #force_inline proc(cpu: ^Cpu, x: u8) {
	cpu.v_register[0xF] = 0
	if cpu.idx_register + u16(cpu.v_register[x]) > 0xFFF {
		cpu.v_register[0xF] = 1
	}
	cpu.idx_register += u16(cpu.v_register[x])
}

LD_F :: #force_inline proc(cpu: ^Cpu, x: u8) {
	cpu.idx_register = u16(cpu.v_register[x] * 0x5)
}

LD_B :: #force_inline proc(cpu: ^Cpu, x: u8) {
	vx := cpu.v_register[x]
	cpu.memory[cpu.idx_register] = vx / 100
	cpu.memory[cpu.idx_register + 1] = (vx / 10) % 10
	cpu.memory[cpu.idx_register + 2] = vx % 10
}

LD_MEM :: #force_inline proc(cpu: ^Cpu, x: u8) {
	for i in 0 ..< x {
		cpu.memory[cpu.idx_register + u16(i)] = cpu.v_register[i]
	}
}

LD_REG_MEM :: #force_inline proc(cpu: ^Cpu, x: u8) {
	for i in 0 ..< x {
		cpu.v_register[i] = cpu.memory[cpu.idx_register + u16(i)]
	}
}

EXIT :: #force_inline proc(cpu: ^Cpu) {
}

LD_FE :: #force_inline proc(cpu: ^Cpu, x: u8) {
	cpu.idx_register = u16(80 + cpu.v_register[x] * 0xA)
}

STR_RPL :: #force_inline proc(cpu: ^Cpu, x: u8) {
	if x < 8 {
		for i in 0 ..< x {
			cpu.rpl_flag[x] = cpu.v_register[x]
		}
	}
}

LD_RPL :: #force_inline proc(cpu: ^Cpu, x: u8) {
	if x < 8 {
		for i in 0 ..< x {
			cpu.v_register[x] = cpu.rpl_flag[x]
		}
	}
}

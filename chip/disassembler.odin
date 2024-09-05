package chip

import "core:log"
import "core:os"
import "core:fmt"
import str "core:strings"

Disassembler :: struct {
	cpu: Cpu,
	memory:   [MEMORY_SIZE]u8,
}

InitDisassembler :: proc() -> ^Disassembler {
	disassembler := new(Disassembler)
	disassembler^ = Disassembler{
		InitCpu(),
		[MEMORY_SIZE]u8{},
	}
	disassembler.cpu.memory = &disassembler.memory
	return disassembler
}

Disassemble :: proc(filename: string) {
	disassembler := InitDisassembler()
	file_error := LoadRomIntoMemory(filename, &disassembler.memory)
	
	if file_error != nil  {
		log.errorf("Error while trying to load file into memory '%s': %v\n", filename, file_error)
		os.exit(1)
	}

	file_handler, create_error := CreateFile("truc.ch8")
	if create_error != nil  {
		log.errorf("Error while trying to create file '%s': %v\n", filename, create_error)
		os.exit(1)
	}

	defer DeleteFileHandler(file_handler)

	IterateOntoMemory(disassembler, file_handler)
}

IterateOntoMemory :: proc(disassembler : ^Disassembler, file_handler: ^FileHandler) {
	for {
		opcode := Fetch(&disassembler.cpu)
		if disassembler.cpu.program_counter == OFFSET_START_PROGRAM + 500 { break }
		nibble := Decode(opcode)
		DisExecute(&disassembler.cpu, nibble, file_handler.fd)
	}
}

DisExecute :: proc(cpu: ^Cpu, nibble: Nibble, fd: os.Handle) {
	op := nibble.opcode
	switch op & 0xF000 {
	case 0x0000:
		switch op & 0x000F {
		case 0x0000:
			fmt.fprintf(fd, "CLS", newline=true)
		case 0x000E:
			fmt.fprintf(fd, "RET", newline=true)
		}
	case 0x1000:
		fmt.fprintf(fd, "JP %i", nibble.nnn, newline=true)
	case 0x2000:
		fmt.fprintf(fd, "CALL %i", nibble.nnn, newline=true)
	case 0x3000:
		fmt.fprintf(fd, "SE vX %i", nibble.nn, newline=true)
	case 0x4000:
		fmt.fprintf(fd, "SNE vX %i", nibble.nn, newline=true)
	case 0x5000:
		fmt.fprintf(fd, "SE_REG vX vY", newline=true)
	case 0x6000:
		fmt.fprintf(fd, "LD vX %i", nibble.nn, newline=true)
	case 0x7000:
		fmt.fprintf(fd, "ADD vX %i", nibble.nn, newline=true)
	case 0x8000:
		switch op & 0x000F {
		case 0x0000:
			fmt.fprintf(fd, "LD_REG vX vY", newline=true)
		case 0x0001:
			fmt.fprintf(fd, "OR vX vY", newline=true)
		case 0x0002:
			fmt.fprintf(fd, "AND vX vY", newline=true)
		case 0x0003:
			fmt.fprintf(fd, "XOR vX vY", newline=true)
		case 0x0004:
			fmt.fprintf(fd, "ADD_REG vX vY", newline=true)
		case 0x0005:
			fmt.fprintf(fd, "SUB vX vY", newline=true)
		case 0x0006:
			fmt.fprintf(fd, "SHR vX", newline=true)
		case 0x0007:
			fmt.fprintf(fd, "SUBN vX vY", newline=true)
		case 0x000E:
			fmt.fprintf(fd, "SHL vX", newline=true)
			default: {log.info("Unknown opcode in 0x8000 switch: 0x%X\n", nibble.opcode)}
		}
	case 0x9000:
		fmt.fprintf(fd, "SNE_REG vX vY", newline=true)
	case 0xA000:
		fmt.fprintf(fd, "LD_I %i", nibble.nnn, newline=true)
	case 0xB000:
		fmt.fprintf(fd, "JP_V0 %i", nibble.nnn, newline=true)
	case 0xC000:
		fmt.fprintf(fd, "RND vX %i", nibble.nn, newline=true)
	case 0xD000:
		fmt.fprintf(fd, "DRW vX vY %i", nibble.n, newline=true)
	case 0xE000:
		switch op & 0x00FF {
		case 0x009E:
			fmt.fprintf(fd, "SKP vX", newline=true)
		case 0x00A1:
			fmt.fprintf(fd, "SKNP vX", newline=true)
		case:
			log.info("Unknown opcode in 0xE000 switch: 0x%X\n", op)
		}
	case 0xF000:
		switch op & 0x00FF {
		case 0x0007:
			fmt.fprintf(fd, "LD_REG_DT vX", newline=true)
		case 0x000A:
			fmt.fprintf(fd, "LD_KEY vX", newline=true)
		case 0x0015:
			fmt.fprintf(fd, "LD_DT vX", newline=true)
		case 0x0018:
			fmt.fprintf(fd, "LD_ST vX", newline=true)
		case 0x001E:
			fmt.fprintf(fd, "ADD_I vX", newline=true)
		case 0x0029:
			fmt.fprintf(fd, "LD_F vX", newline=true)
		case 0x0030:
			fmt.fprintf(fd, "LD_FE vX", newline=true)
		case 0x0033:
			fmt.fprintf(fd, "LD_B vX", newline=true)
		case 0x0055:
			fmt.fprintf(fd, "LD_MEM vX", newline=true)
		case 0x0065:
			fmt.fprintf(fd, "LD_REG_MEM vX", newline=true)
		case 0x0075:
			fmt.fprintf(fd, "STR_RPL vX", newline=true)
		case 0x0085:
			fmt.fprintf(fd, "LD_RPL vX", newline=true)
		case:
			log.info("Unknown opcode in 0xF000 switch: 0x%X\n", op)
		}
	case:
		log.info("Unknown main switch opcode: 0x%X\n", op)
	}
}


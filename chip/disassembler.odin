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
	defer free(disassembler)
	file_error := LoadRomIntoMemory(filename, &disassembler.memory)
	
	if file_error != nil  {
		log.errorf("Error while trying to load file into memory '%s': %v\n", filename, file_error)
		os.exit(1)
	}

	rom_name, mem_err := GetRomName(filename)
	defer delete(rom_name)

	if mem_err != nil {
		log.errorf("Memory allocation error %v\n", mem_err)
		os.exit(1)
	}

	res, concat_error := str.concatenate({rom_name, ".asm"}, context.temp_allocator)
	defer delete(res)

	if concat_error != nil  {
		log.errorf("Memory allocation error %v\n", concat_error)
		os.exit(1)
	}


	file_handler, create_error := CreateFile(res)
	if create_error != nil  {
		log.errorf("Error while trying to create file '%s': %v\n", filename, create_error)
		os.exit(1)
	}

	defer DeleteFileHandler(file_handler)

	IterateOntoMemory(disassembler, file_handler)
}

IterateOntoMemory :: proc(disassembler : ^Disassembler, file_handler: ^FileHandler) {
	last_opcode : u16 = 1
	for {
		nibble := Decode(Fetch(&disassembler.cpu))
		if nibble.opcode == 0 && last_opcode == 0 { break }
		last_opcode = nibble.opcode
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
		fmt.fprintf(fd, "JP 0x%X", nibble.nnn, newline=true)
	case 0x2000:
		fmt.fprintf(fd, "CALL 0x%X", nibble.nnn, newline=true)
	case 0x3000:
		fmt.fprintf(fd, "SE X%i, %i", nibble.x, nibble.nn, newline=true)
	case 0x4000:
		fmt.fprintf(fd, "SNE X%i, %i", nibble.x, nibble.nn, newline=true)
	case 0x5000:
		fmt.fprintf(fd, "SE_REG X%i, Y%i", nibble.x,  nibble.y, newline=true)
	case 0x6000:
		fmt.fprintf(fd, "LD X%i, %i", nibble.x, nibble.nn, newline=true)
	case 0x7000:
		fmt.fprintf(fd, "ADD X%i, %i", nibble.x, nibble.nn, newline=true)
	case 0x8000:
		switch op & 0x000F {
		case 0x0000:
			fmt.fprintf(fd, "LD_REG X%i, Y%i", nibble.x,  nibble.y, newline=true)
		case 0x0001:
			fmt.fprintf(fd, "OR X%i, Y%i", nibble.x,  nibble.y, newline=true)
		case 0x0002:
			fmt.fprintf(fd, "AND X%i, Y%i", nibble.x,  nibble.y, newline=true)
		case 0x0003:
			fmt.fprintf(fd, "XOR X%i, Y%i", nibble.x,  nibble.y, newline=true)
		case 0x0004:
			fmt.fprintf(fd, "ADD_REG X%i, Y%i", nibble.x,  nibble.y, newline=true)
		case 0x0005:
			fmt.fprintf(fd, "SUB X%i, Y%i", nibble.x,  nibble.y, newline=true)
		case 0x0006:
			fmt.fprintf(fd, "SHR X%i", nibble.x, newline=true)
		case 0x0007:
			fmt.fprintf(fd, "SUBN X%i, Y%i", nibble.x,  nibble.y, newline=true)
		case 0x000E:
			fmt.fprintf(fd, "SHL X%i", nibble.x, newline=true)
			default: {log.info("Unknown opcode in 0x8000 switch: 0x%X\n", nibble.opcode)}
		}
	case 0x9000:
		fmt.fprintf(fd, "SNE_REG X%i, Y%i", nibble.x,  nibble.y, newline=true)
	case 0xA000:
		fmt.fprintf(fd, "LD_I %i", nibble.nnn, newline=true)
	case 0xB000:
		fmt.fprintf(fd, "JP_V0 0x%X", nibble.nnn, newline=true)
	case 0xC000:
		fmt.fprintf(fd, "RND X%i, %i", nibble.x, nibble.nn, newline=true)
	case 0xD000:
		fmt.fprintf(fd, "DRW X%i, Y%i, %i", nibble.x, nibble.y, nibble.n, newline=true)
	case 0xE000:
		switch op & 0x00FF {
		case 0x009E:
			fmt.fprintf(fd, "SKP X%i", nibble.x, newline=true)
		case 0x00A1:
			fmt.fprintf(fd, "SKNP X%i", nibble.x, newline=true)
		case:
			log.info("Unknown opcode in 0xE000 switch: 0x%X\n", op)
		}
	case 0xF000:
		switch op & 0x00FF {
		case 0x0007:
			fmt.fprintf(fd, "LD_REG_DT X%i", nibble.x, newline=true)
		case 0x000A:
			fmt.fprintf(fd, "LD_KEY X%i", nibble.x, newline=true)
		case 0x0015:
			fmt.fprintf(fd, "LD_DT X%i", nibble.x, newline=true)
		case 0x0018:
			fmt.fprintf(fd, "LD_ST X%i", nibble.x, newline=true)
		case 0x001E:
			fmt.fprintf(fd, "ADD_I X%i", nibble.x, newline=true)
		case 0x0029:
			fmt.fprintf(fd, "LD_F X%i", nibble.x, newline=true)
		case 0x0030:
			fmt.fprintf(fd, "LD_FE X%i", nibble.x, newline=true)
		case 0x0033:
			fmt.fprintf(fd, "LD_B X%i", nibble.x, newline=true)
		case 0x0055:
			fmt.fprintf(fd, "LD_MEM X%i", nibble.x, newline=true)
		case 0x0065:
			fmt.fprintf(fd, "LD_REG_MEM X%i", nibble.x, newline=true)
		case 0x0075:
			fmt.fprintf(fd, "STR_RPL X%i", nibble.x, newline=true)
		case 0x0085:
			fmt.fprintf(fd, "LD_RPL X%i", nibble.x, newline=true)
		case:
			log.info("Unknown opcode in 0xF000 switch: 0x%X\n", op)
		}
	case:
		log.info("Unknown main switch opcode: 0x%X\n", op)
	}
}


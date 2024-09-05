package chip

// Init Cpu 
// Open a file with the same name but change the extension to asm8
// Set a dissassembly mode so instead of calling instructions it call dissassembly instructions or just duplicate ? 
// Write line by line inside the file
// Close the program

import "core:log"
import "core:os"

disasembler : Disassembler 

Disassembler :: struct {
	cpu: Cpu,
	memory:   [MEMORY_SIZE]u8,
}


Disassemble :: proc(filename: string) {

}

/*InitDisassembler :: proc(file_name: string) -> Disassembler {
	disasembler = Disassembler{
		InitCpu(),
		[MEMORY_SIZE]u8{},
	}

	if !load_rom(file_name, &disasembler.memory) {
		log.error("Impossible to load the rom")
		os.exit(1)
	}

}
*/


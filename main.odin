package main

import str "core:strings"
import "core:log"
import "core:os"
import "core:reflect"

import "chip"

Version :: "0.0.1"

Command :: enum {
	PLAY,
	DISASSEMBLE
}

main :: proc() {

	arguments := os.args[1:]
	context.logger = log.create_console_logger()
	defer log.destroy_console_logger(context.logger)

	if len(arguments) != 2 {
		log.error("Usage : chip <command> <filename>\n")
		os.exit(1)
	}

	commandname := arguments[0]
	filename := arguments[1]

	command, ok := reflect.enum_from_name_any(Command, str.to_upper(commandname))

	if !ok {
		log.warn("Command not recognized. Play mode is set by default \n")
	}

	switch Command(command) {
	case Command.PLAY:
		chip.Play(filename)
	case Command.DISASSEMBLE:
		chip.Disassemble(filename)
	}
}

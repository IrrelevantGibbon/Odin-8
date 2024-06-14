package main

import "chip"
import rl "vendor:raylib"


main :: proc() {
	chip_8 := chip.init_chip()
	defer free(chip_8)
	chip.init_window()
	defer chip.shutdown_window()
	for !rl.WindowShouldClose() {
		chip.chip_loop(chip_8)
	}
}

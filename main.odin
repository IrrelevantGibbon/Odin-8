package main

import "chip"
import rl "vendor:raylib"


main :: proc() {
	chip.init_window()
	for !rl.WindowShouldClose() {
		chip.draw_on_screen()
	}
	defer chip.shutdown_window()
}

package chip

import rl "vendor:raylib"

WINDOW_FLAGS :: rl.ConfigFlags{.WINDOW_HIGHDPI}
WINDOW_WIDTH :: 640
WINDOW_HEIGHT :: 320

when CHIP_TYPE == ChipType.SCHIP {WINDOW_NAME :: "Super Chip-48"} else {WINDOW_NAME :: "Chip-8"}


init_window :: proc() {
	rl.SetTraceLogLevel(.WARNING)
	rl.SetConfigFlags(WINDOW_FLAGS)
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, WINDOW_NAME)
	rl.InitAudioDevice()
}

shutdown_window :: proc() {
	rl.CloseAudioDevice()
	rl.CloseWindow()
}

draw_on_screen :: proc(screen: ^Screen) {
	rl.BeginDrawing()
	rl.ClearBackground(rl.BLACK)

	for x in 0 ..< SCREEN_WIDTH {
		for y in 0 ..< SCREEN_HEIGHT {
			i := y * SCREEN_WIDTH + x
			if screen.frame[i] == 1 {
				rl.DrawRectangle(i32(x) * 10, i32(y) * 10, 10, 10, rl.RAYWHITE)
			}
		}
	}
	rl.EndDrawing()
}

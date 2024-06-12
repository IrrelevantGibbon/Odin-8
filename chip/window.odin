package chip

import rl "vendor:raylib"

WINDOW_FLAGS :: rl.ConfigFlags{.WINDOW_HIGHDPI}
WINDOW_WIDTH :: 640
WINDOW_HEIGHT :: 480

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

draw_on_screen :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.BLACK)
	rl.EndDrawing()
}

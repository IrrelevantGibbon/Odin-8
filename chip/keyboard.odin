package chip

import rl "vendor:raylib"

KeyboardInput :: [16]rl.KeyboardKey {
	rl.KeyboardKey.X,
	rl.KeyboardKey.A,
	rl.KeyboardKey.Z,
	rl.KeyboardKey.E,
	rl.KeyboardKey.Q,
	rl.KeyboardKey.W,
	rl.KeyboardKey.R,
	rl.KeyboardKey.U,
	rl.KeyboardKey.S,
	rl.KeyboardKey.D,
	rl.KeyboardKey.I,
	rl.KeyboardKey.C,
	rl.KeyboardKey.UP,
	rl.KeyboardKey.DOWN,
	rl.KeyboardKey.F,
	rl.KeyboardKey.V,
}

get_keyboard_event :: proc(keyboard: ^[16]u8) {
	get_keyup_event(keyboard)
	get_keydown_event(keyboard)
}

get_keyup_event :: proc(keyboard: ^[16]u8) {
	keyboard := keyboard
	for input, idx in KeyboardInput {
		if rl.IsKeyUp(input) {
			keyboard[idx] = 0x0
		}
	}
}

get_keydown_event :: proc(keyboard: ^[16]u8) {
	keyboard := keyboard
	for input, idx in KeyboardInput {
		if rl.IsKeyDown(input) {
			keyboard[idx] = 0x1
		}
	}
}

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

GetKeyboardEvent :: proc(keyboard: ^[16]u8) {
	GetKeyupEvent(keyboard)
	GetKeydownEvent(keyboard)
}

GetKeyupEvent :: proc(keyboard: ^[16]u8) {
	keyboard := keyboard
	for input, idx in KeyboardInput {
		if rl.IsKeyUp(input) {
			keyboard[idx] = 0x0
		}
	}
}

GetKeydownEvent :: proc(keyboard: ^[16]u8) {
	keyboard := keyboard
	for input, idx in KeyboardInput {
		if rl.IsKeyDown(input) {
			keyboard[idx] = 0x1
		}
	}
}

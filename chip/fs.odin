package chip

import "core:os"
import "core:log"

FileError :: union {
	UnableToOpen,
	UnableToRead,
	SizeError
}

FsError :: struct {
	filename: string,
	description: os.Errno
}

UnableToOpen :: distinct FsError
UnableToRead :: distinct FsError
SizeError :: distinct FsError

LoadRomIntoMemory :: proc(filename: string, memory: ^[MEMORY_SIZE]u8) -> FileError {
	file, open_error := os.open(filename, os.O_RDWR)
	defer os.close(file)
	
	if open_error != os.ERROR_NONE {
		return UnableToOpen{filename, open_error}
	}

	size, size_error := os.file_size(file)

	if size_error != 0  && size > len(memory) - OFFSET_START_PROGRAM {
		return SizeError{filename, size_error}
	}

	read_bytes, read_error := os.read_ptr(file, &memory[OFFSET_START_PROGRAM], int(size))
	if read_bytes != int(size) {
		return UnableToRead{filename, read_error}
	}
	return nil
}

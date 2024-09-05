package chip

import "core:os"
import "core:log"

FileError :: union {
	UnableToOpen,
	UnableToRead,
	UnableToWrite,
	UnableToClose,
	SizeError
}

FsError :: struct {
	filename: string,
	description: os.Errno
}

FileHandler :: struct {
	fd: os.Handle,
	filename: string,
	offset: i64
}

UnableToOpen :: distinct FsError
UnableToRead :: distinct FsError
UnableToWrite :: distinct FsError
UnableToClose :: distinct FsError
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


CreateFile :: proc(filename: string) -> (^FileHandler, FileError) {
	file_descriptor, open_error := os.open(filename, os.O_APPEND | os.O_CREATE)

	if open_error != os.ERROR_NONE {
		return nil, UnableToOpen{filename, open_error}
	}

	file_handler := new(FileHandler)
	file_handler^ = FileHandler {
		file_descriptor,
		filename,
		0
	}
	return file_handler, nil
}


DeleteFileHandler :: proc(file_handler: ^FileHandler) -> FileError {
	fd := file_handler.fd
	filename := file_handler.filename

	free(file_handler)

	close_error := os.close(file_handler.fd)
	if close_error != os.ERROR_NONE {
		return UnableToClose{filename, close_error}
	}

	return nil
}
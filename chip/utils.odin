package chip

import "core:strings"
import "core:mem"
import "core:os"

/*
	#TODO : Filepath since the start should have been a Path struct but for the moment it's ok like that
*/

GetRomName :: proc(filepath: string) -> (res: string, err: mem.Allocator_Error)  {
	names := strings.split(filepath, "\\", context.temp_allocator) or_return
	rom_name := strings.split(names[len(names) -1:][0], ".", context.temp_allocator) or_return
	return rom_name[0], nil
}
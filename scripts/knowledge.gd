extends Node

signal flag_set(flag: String)

var flags: Dictionary = {}      # String -> true

func has(f: String) -> bool: return flags.has(f)
func has_all(fs: Array) -> bool:
	for f in fs: if not flags.has(f): return false
	return true

func grant(f: String) -> void:
	if flags.has(f): return
	flags[f] = true
	flag_set.emit(f)

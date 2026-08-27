extends Node

var knowledge := []

func has_all(requirements: Array) -> bool:
	for requirement in requirements:
		if (!knowledge.has(requirement)):
			return false
	return true

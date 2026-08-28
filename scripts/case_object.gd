class_name CaseObject
extends Node2D

@export var cases: Array[String] = []
@export var requires: Array[String] = []
@export var forbids: Array[String] = []

func _ready():
	if (CaseState.current.id not in cases):
		queue_free()

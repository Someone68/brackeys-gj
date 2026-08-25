extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.dialog_node = $DialogBox
	Global.dialog_initialized = true
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

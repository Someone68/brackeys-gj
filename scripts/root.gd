extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(2).timeout
	$DialogBox.show_dialog(["testetstest. testtest, testestestes! test. this is some very long text to test the dialog.", "this is more text to test multiple dialogs."])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

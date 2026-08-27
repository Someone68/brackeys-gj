extends Area2D

@export var target_room: String
@export var target_spawn: String = "default"
@export var locked_text: String = "Locked."
@export var flags_required: Array[String] = []
@export var pushback: float = 2.0
@export var interact_required := false

func _on_body_entered(body: Node2D) -> void:
	if (body is Player and !interact_required):
		if (Knowledge.has_all(flags_required)):
			RoomManager.goto(target_room, target_spawn)
		else:
			var away := (body.global_position - global_position).normalized()
			if away == Vector2.ZERO:
				away = Vector2.DOWN
			body.global_position += away * pushback
			body.velocity = Vector2.ZERO
			Global.show_dialog([locked_text])

func _interact():
	if interact_required:
		if (Knowledge.has_all(flags_required)):
			RoomManager.goto(target_room, target_spawn)
		else:
			Global.show_dialog([locked_text])

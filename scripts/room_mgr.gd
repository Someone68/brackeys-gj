extends Node
signal room_changed(room_id: String)

var host: Node2D
var player: Node2D
var current_id: String = ""
var _transitioning := false

const ROOMS := {
	"town_square": "res://scenes/rooms/town_square.tscn",
	"left_branch": "res://scenes/rooms/left_branch.tscn"
}

func goto(room_id: String, spawn_name: String = "default") -> void:
	if _transitioning: return
	if not ROOMS.has(room_id):
		push_error("no room: " + room_id); return
	player.in_transition = true
	
	await Fade.fade_out()
	for c in host.get_children():
		c.queue_free()
	await get_tree().process_frame
	
	var room = load(ROOMS[room_id]).instantiate()
	host.add_child(room)
	await get_tree().process_frame
	current_id = room_id
	
	var spawn = room.get_node_or_null("Spawns/" + spawn_name)
	if spawn == null:
		push_error("no spawn '%s' in %s" % [spawn_name, room_id])
	player.global_position = spawn.global_position if spawn else Vector2.ZERO

	_fit_camera(room)
	room_changed.emit(room_id)
	await Fade.fade_in()
	_transitioning = false
	player.in_transition = false
	
func _fit_camera(room: Node2D) -> void:
	var cam := player.get_parent().get_node("Camera2D")
	var tm := room.get_node_or_null("Floor") as TileMapLayer
	if tm == null:
		cam._has_bounds = false
		cam.snap()
		return
	var r := tm.get_used_rect()
	if r.size == Vector2i.ZERO:
		cam._has_bounds = false
		cam.snap()
		return
	var ts := tm.tile_set.tile_size
	cam.set_bounds(Rect2(
		Vector2(r.position.x * ts.x, r.position.y * ts.y),
		Vector2(r.size.x * ts.x, r.size.y * ts.y)
	))
	cam.snap()

extends Camera2D

@export var target: Node2D
@export var smooth_speed: float = 8.0
@export var snap_dist: float = 4.0

var _bounds := Rect2()
var _has_bounds := false

func _ready() -> void:
	position_smoothing_enabled = false
	ignore_rotation = true
	if target:
		global_position = _clamped(target.global_position)

func _physics_process(delta: float) -> void:
	if target == null: return
	var want := _clamped(target.global_position)
	if global_position.distance_to(want) < snap_dist:
		global_position = want
	else:
		global_position = global_position.lerp(want, 1.0 - exp(-smooth_speed * delta))

func _clamped(p: Vector2) -> Vector2:
	if not _has_bounds: return p
	var half := get_viewport_rect().size * 0.5 / zoom
	var out := p

	if _bounds.size.x <= half.x * 2.0:
		out.x = _bounds.position.x + _bounds.size.x * 0.5
	else:
		out.x = clampf(p.x, _bounds.position.x + half.x, _bounds.end.x - half.x)

	if _bounds.size.y <= half.y * 2.0:
		out.y = _bounds.position.y + _bounds.size.y * 0.5
	else:
		out.y = clampf(p.y, _bounds.position.y + half.y, _bounds.end.y - half.y)
	return out

func set_bounds(r: Rect2) -> void:
	_bounds = r
	_has_bounds = true

func snap() -> void:
	if target == null:
		push_error("camera target unset")
		return
	if target:
		global_position = _clamped(target.global_position)
		reset_physics_interpolation()
	print("snap -> ", global_position, " (player ", target.global_position, ")")
	

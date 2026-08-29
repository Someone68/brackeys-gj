extends Control

signal picked(index: int)

@export var spacing := 24
@export var fade := 0.35
@export var wrap := true
@export var anim_time := 0.18
@export var enabled := false
@export var chosen := false
@export var items: Array[SelectorItem] = []:
	set(v):
		items = v
		if is_node_ready(): _rebuild()

@export var font_size := 8

@onready var track: HBoxContainer = $Track
var index := 0
var tween: Tween

func _ready() -> void:
	focus_mode = Control.FOCUS_ALL
	clip_contents = true
	track.add_theme_constant_override("separation", spacing)
	_rebuild()

func _unhandled_input(e: InputEvent) -> void:
	if (enabled and not Global.dialog_visible and not Global.choice_visible and not Global.notes_visible):
		if e.is_action_pressed("right", true):
			_move(1); accept_event()
		elif e.is_action_pressed("left", true):
			_move(-1); accept_event()
		elif e.is_action_pressed("interact"):
			picked.emit(index); accept_event()

func _move(dir: int) -> void:
	var n := track.get_child_count()
	if n == 0: return
	index = wrapi(index + dir, 0, n) if wrap else clampi(index + dir, 0, n - 1)
	refresh(true)

@onready var caption: Label = $Caption

func refresh(animate: bool) -> void:
	if track.get_child_count() == 0:
		caption.text = ""
		return

	var sel := track.get_child(index) as Control
	var target_x := roundf(size.x * 0.5 - (sel.position.x + sel.size.x * 0.5))
	var t := anim_time if animate else 0.0

	caption.text = items[index].caption if index < items.size() else ""

	if tween: tween.kill()
	tween = create_tween().set_parallel(true)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_method(_set_track_x, track.position.x, target_x, t)

	for i in track.get_child_count():
		var c := track.get_child(i) as Control
		if (not chosen and not enabled):
			tween.tween_property(c, "modulate:a", fade, t)
			continue
		tween.tween_property(c, "modulate:a", 1.0 if i == index else 0.0 if chosen else fade, t)

func _set_track_x(x: float) -> void:
	track.position.x = roundf(x)

func _build_item(data: SelectorItem) -> Control:
	var tr := TextureRect.new()
	tr.texture = data.texture
	tr.expand_mode = TextureRect.EXPAND_KEEP_SIZE
	tr.stretch_mode = TextureRect.STRETCH_KEEP
	tr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tr.size_flags_vertical = Control.SIZE_SHRINK_END
	return tr

func _rebuild() -> void:
	for c in track.get_children():
		c.queue_free()
		track.remove_child(c)
	for data in items:
		if data: track.add_child(_build_item(data))
	index = clampi(index, 0, maxi(0, items.size() - 1))
	await get_tree().process_frame
	refresh(false)
	

extends CanvasLayer

const DUR := 0.25

var rect: ColorRect
var _tween: Tween

func _ready() -> void:
	layer = 128
	rect = ColorRect.new()
	rect.color = Color.BLACK
	rect.color.a = 0.0
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(rect)

func fade_out(dur: float = DUR) -> void:
	await _to(1.0, dur)

func fade_in(dur: float = DUR) -> void:
	await _to(0.0, dur)

func _to(alpha: float, dur: float) -> void:
	if _tween and _tween.is_running():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(rect, "color:a", alpha, dur)
	await _tween.finished

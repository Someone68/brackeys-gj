extends CharacterBody2D

@export var speed := 100.0
@export var INTERACT_RANGE := 24.0
@export var FEET_OFFSET := Vector2(0, 0)

@onready var ray: RayCast2D = $RayCast2D
var facing := Vector2(1, 0)
var can_move := true
var can_interact := true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	can_move = not Global.dialog_visible
	can_interact = not Global.dialog_visible
	
	var input_direction = Input.get_vector("left", "right", "up", "down") if can_move else Vector2.ZERO
	if (not input_direction.is_zero_approx()):
		facing = input_direction.normalized()
		ray.target_position = facing * INTERACT_RANGE
	velocity = input_direction * speed
	
	move_and_slide()
	
func update_ray() -> void:
	ray.target_position = facing * INTERACT_RANGE
	if abs(facing.x) > abs(facing.y):
		ray.position = FEET_OFFSET
	else:
		ray.position = Vector2.ZERO

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		try_interact()

func try_interact() -> void:
	if not can_interact:
		return
	if not ray.is_colliding():
		return
	var c = ray.get_collider()
	if c.is_in_group("interactable") and c.has_method("interact"):
		c.interact()

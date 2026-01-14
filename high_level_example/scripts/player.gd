extends CharacterBody2D

@onready var camera_2d: Camera2D = $Camera2D

@export var SPEED: float = 30000
@export var GRAVITY = 3000
const JUMP_VEL = -1000

enum states {NORMAL, LOWGRAV, HIGHSPEED}

var state: states = states.NORMAL

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())
	print(name.to_int())
	print(name)

func _process(delta: float) -> void:
	if !is_multiplayer_authority(): return
	match state:
		states.NORMAL:
			SPEED = 30000
			GRAVITY = 3000
		states.LOWGRAV:
			GRAVITY = 2000
		states.HIGHSPEED:
			SPEED = 35000
			GRAVITY = 3000

func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority(): return
	camera_2d.make_current()
	velocity.x = Input.get_axis("ui_left", "ui_right") * delta * SPEED
	if !is_on_floor():
		velocity.y += GRAVITY * delta
	if Input.is_action_just_pressed("jump") && is_on_floor():
		velocity.y = JUMP_VEL
	move_and_slide()
	if Input.is_action_just_pressed("cycle"):
		match state:
			states.NORMAL:
				state = states.LOWGRAV
			states.LOWGRAV:
				state = states.HIGHSPEED
			states.HIGHSPEED:
				state = states.NORMAL

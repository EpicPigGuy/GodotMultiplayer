extends CharacterBody2D

@export var sequential_id: int = 0
@onready var camera_2d: Camera2D = $Camera2D
@onready var icon: Sprite2D = $Icon

const ACCELERATION : float = 8000.0 # Rate of increase
const DECELERATION : float = 10000.0 # Rate of decrease (can be higher than acceleration for snappier stops)
const BASE_SPEED: float = 800
const HIGH_SPEED: float = 1000
const BASE_GRAVITY: float = 3000
const LOW_GRAVITY: float = 2000
const JUMP_VEL: float = -1000

enum states {NORMAL, LOWGRAV, HIGHSPEED}
var state: states = states.NORMAL
var flip = false

func _ready() -> void:
	await get_tree().process_frame
	print("PLAYER READY:", name,
		"| My ID:", multiplayer.get_unique_id(),
		"| Authority:", get_multiplayer_authority())
	if get_multiplayer_authority() == multiplayer.get_unique_id():
		camera_2d.make_current()
		print("Camera activated for player:", name)

func get_speed() -> float:
	match state:
		states.NORMAL: return BASE_SPEED
		states.LOWGRAV: return BASE_SPEED
		states.HIGHSPEED: return HIGH_SPEED
	return BASE_SPEED

func get_gravity_strength() -> float:
	match state:
		states.NORMAL: return BASE_GRAVITY
		states.LOWGRAV: return LOW_GRAVITY
		states.HIGHSPEED: return BASE_GRAVITY
	return BASE_GRAVITY



func _physics_process(delta: float) -> void:
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		return
	var direction_x : float = Input.get_axis("ui_left", "ui_right")

	if direction_x != 0:
		velocity.x = move_toward(velocity.x, direction_x * get_speed(), ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, DECELERATION * delta)
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VEL
	move_and_slide()
	if Input.is_action_just_pressed("cycle"):
		match state:
			states.NORMAL: state = states.LOWGRAV
			states.LOWGRAV: state = states.HIGHSPEED
			states.HIGHSPEED: state = states.NORMAL
	if position.y >= 1100:
		position = Vector2(0, 0)
	if velocity.x < 0:
		flip = true
	else:
		flip = false
	icon.flip_h = flip

@rpc("any_peer", "call_local")
func callPlayer(input_pos: Vector2) -> void:
	print("Teleport on peer:", multiplayer.get_unique_id())
	position = input_pos + Vector2(0, (sequential_id - 2) * 50)

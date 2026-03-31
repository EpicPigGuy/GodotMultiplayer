extends CharacterBody2D

@export var sequential_id: int = 0
@onready var camera_2d: Camera2D = $Camera2D
@onready var icon: Sprite2D = $Icon

const ACCELERATION: float = 8000.0
const DECELERATION: float = 10000.0
const BASE_SPEED: float = 600
const HIGH_SPEED: float = 800
const BASE_GRAVITY: float = 3000
const LOW_GRAVITY: float = 2500
const JUMP_VEL: float = -1100
var SPAWN_POS = Vector2(0, 0)

enum states {NORMAL, LOWGRAV, HIGHSPEED}
var state: states = states.NORMAL
var flip = false

func _ready() -> void:
	await get_tree().process_frame
	print("PLAYER READY:", name, "| My ID:", multiplayer.get_unique_id(), "| Authority:", get_multiplayer_authority())
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

	# Apply gravity if not on the floor
	if not is_on_floor():
		velocity.y += get_gravity_strength() * delta

	var direction_x: float = Input.get_axis("ui_left", "ui_right")
	if direction_x != 0:
		velocity.x = move_toward(velocity.x, direction_x * get_speed(), ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, DECELERATION * delta)

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VEL

	# Move the character
	move_and_slide()

	# Handle state switching
	if Input.is_action_just_pressed("cycle"):
		match state:
			states.NORMAL: state = states.LOWGRAV
			states.LOWGRAV: state = states.HIGHSPEED
			states.HIGHSPEED: state = states.NORMAL

	# Boundary Reset
	if position.y >= 1100:
		position = SPAWN_POS

	# Flip Sprite
	flip = velocity.x < 0
	icon.flip_h = flip

@rpc("any_peer", "call_local")
func callPlayer(input_pos: Vector2) -> void:
	print("Teleport on peer:", multiplayer.get_unique_id())
	position = input_pos + Vector2(0, (sequential_id - 2) * 50)
	SPAWN_POS = input_pos

@rpc("any_peer", "call_local")
func changeScene(scene_path: String) -> void:
	if scene_path and (scene_path.ends_with(".tscn") or scene_path.ends_with(".scn")):
		get_tree().change_scene_to_file(scene_path)
	else:
		print("Invalid scene path provided via RPC: ", scene_path)

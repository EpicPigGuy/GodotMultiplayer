extends CharacterBody2D

@export var sequential_id: int = 0
@onready var camera_2d: Camera2D = $Camera2D
@onready var icon: Sprite2D = $Icon
@onready var under_check: RayCast2D = $UnderCheck
@onready var under_check_2: RayCast2D = $UnderCheck2

const ACCELERATION: float = 8000.0
const DECELERATION: float = 10000.0
const BASE_SPEED: float = 600
const HIGH_SPEED: float = 800
const BASE_GRAVITY: float = 3000
const LOW_GRAVITY: float = 2500
const JUMP_VEL: float = -1100

var SPAWN_POS = Vector2(0, 0)
var time_since_grounded = 0

enum states {NORMAL, LOWGRAV, HIGHSPEED, SLOW}
var state: states = states.NORMAL

var standing_on_player: CharacterBody2D = null

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

# --- NEW: RAYCAST PLAYER DETECTION ---
func get_player_below() -> CharacterBody2D:
	var checks = [under_check, under_check_2]

	for ray in checks:
		if ray.is_colliding():
			var collider = ray.get_collider()
			if collider != null and collider != self and collider.is_in_group("players"):
				return collider

	return null

func _physics_process(delta: float) -> void:
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		return

	var on_floor = is_on_floor()
	standing_on_player = get_player_below()

	# --- GROUND TIMER ---
	if on_floor or standing_on_player:
		time_since_grounded = 0
	else:
		time_since_grounded += delta

	# --- GRAVITY & PLAYER STACKING ---
	if standing_on_player:
		# Stop downward motion
		if velocity.y > 0:
			velocity.y = 0

		# Inherit horizontal movement
		velocity.x += standing_on_player.velocity.x * 0.9

		# Snap to top of player using raycast
		var collision_point = under_check.get_collision_point()
		var target_y = collision_point.y - 64  # adjust to your sprite height
		global_position.y = lerp(global_position.y, target_y, 0.5)

	elif not on_floor:
		velocity.y += get_gravity_strength() * delta

	# --- MOVEMENT INPUT ---
	var direction_x: float = Input.get_axis("ui_left", "ui_right")
	if direction_x != 0:
		velocity.x = move_toward(velocity.x, direction_x * get_speed(), ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, DECELERATION * delta)

	# --- JUMP ---
	if Input.is_action_just_pressed("jump") and time_since_grounded < 0.1:
		velocity.y = JUMP_VEL

	# --- APPLY MOVEMENT ---
	move_and_slide()

	# --- STATE SWITCHING ---
	if Input.is_action_just_pressed("cycle"):
		if state == states.SLOW:
			if Engine.time_scale == 1:
				Engine.time_scale = 0.1
			else:
				Engine.time_scale = 1

	# --- RESPAWN ---
	if position.y >= 1100:
		position = SPAWN_POS + Vector2(0, 32)

	# --- SPRITE FLIP ---
	if velocity.x < 0:
		icon.flip_h = true
	elif velocity.x > 0:
		icon.flip_h = false


@rpc("any_peer", "call_local")
func set_state_rpc(new_state: int) -> void:
	state = new_state
	
	
@rpc("any_peer", "call_local")
func callPlayer(input_pos: Vector2) -> void:
	print("Teleport on peer:", multiplayer.get_unique_id())
	position = input_pos + Vector2(0, (sequential_id - 2) * 50)
	SPAWN_POS = input_pos

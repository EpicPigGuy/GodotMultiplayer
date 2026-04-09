extends CharacterBody2D
@export var sequential_id: int = 0
@onready var camera_2d: Camera2D = $Camera2D
@onready var icon: Sprite2D = $Icon

const ACCELERATION := 7000.0
const DECELERATION := 9000.0
const JUMP_VEL := -1100.0
var SPAWN_POS := Vector2.ZERO
var time_since_grounded := 0.0
var state: int = PlayerState.States.NORMAL
var standing_on_player: CharacterBody2D = null
var last_platform_pos: Vector2 = Vector2.ZERO
var was_standing_on_player := false

func _ready() -> void:
	await get_tree().process_frame
	add_to_group("players")
	if get_multiplayer_authority() == multiplayer.get_unique_id():
		camera_2d.make_current()

func get_player_below() -> CharacterBody2D:
	for i in get_slide_collision_count():
		var col := get_slide_collision(i)
		var collider := col.get_collider()
		if collider != null and collider != self and collider.is_in_group("players"):
			if col.get_normal().y < -0.5:
				return collider
	return null

func _physics_process(delta: float) -> void:
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		return

	var on_floor := is_on_floor()
	standing_on_player = get_player_below()
	var grounded := on_floor or standing_on_player != null

	if grounded:
		time_since_grounded = 0.0
	else:
		time_since_grounded += delta

	# --- PLATFORM RIDING ---
	if standing_on_player != null and was_standing_on_player:
		var platform_delta := standing_on_player.global_position - last_platform_pos
		global_position += platform_delta

	if standing_on_player != null:
		last_platform_pos = standing_on_player.global_position
		was_standing_on_player = true
	else:
		last_platform_pos = Vector2.ZERO
		was_standing_on_player = false

	# --- GRAVITY ---
	if not grounded:
		velocity.y += PlayerState.get_gravity(state) * delta

	# --- HORIZONTAL INPUT ---
	var dir := Input.get_axis("ui_left", "ui_right")
	var target_speed := dir * PlayerState.get_speed(state)
	if dir != 0:
		velocity.x = move_toward(velocity.x, target_speed, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, DECELERATION * delta)

	# --- JUMP ---
	if Input.is_action_just_pressed("jump") and time_since_grounded < 0.1:
		velocity.y = JUMP_VEL
		standing_on_player = null
		was_standing_on_player = false
		last_platform_pos = Vector2.ZERO

	move_and_slide()

	# --- SLOW TIME ---
	if Input.is_action_just_pressed("cycle"):
		if state == PlayerState.States.SLOW:
			Engine.time_scale = 0.1 if Engine.time_scale == 1 else 1

	# --- RESPAWN ---
	if position.y >= 1100:
		position = SPAWN_POS + Vector2(0, 32)

	# --- FLIP ---
	if velocity.x < 0:
		icon.flip_h = true
	elif velocity.x > 0:
		icon.flip_h = false

@rpc("any_peer", "call_local")
func set_state_rpc(new_state: int) -> void:
	state = new_state

@rpc("any_peer", "call_local")
func callPlayer(input_pos: Vector2) -> void:
	position = input_pos + Vector2(0, (sequential_id - 2) * 50)
	SPAWN_POS = input_pos

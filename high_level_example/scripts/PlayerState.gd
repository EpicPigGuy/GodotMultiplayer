extends Node

enum States { NORMAL, LOWGRAV, HIGHSPEED, SLOW }

# Use a variable to actually store the current state
var current_state: States = States.NORMAL

const BASE_SPEED := 600.0
const HIGH_SPEED := 800.0
const BASE_GRAVITY := 3000.0
const LOW_GRAVITY := 2500.0
const JUMP_VEL := -1100.0

func get_state():
	return current_state

func player_get_speed() -> float:
	match current_state:
		States.HIGHSPEED: return HIGH_SPEED
	return BASE_SPEED

func player_get_gravity() -> float:
	match current_state:
		States.LOWGRAV: return LOW_GRAVITY
		_: return BASE_GRAVITY
		
func player_get_jump():
	return JUMP_VEL

func set_state(new_state: States):
	current_state = new_state

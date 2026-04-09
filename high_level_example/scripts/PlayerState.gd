extends Node

enum States { NORMAL, LOWGRAV, HIGHSPEED, SLOW }

# Use a variable to actually store the current state
var current_state: States = States.NORMAL

const BASE_SPEED := 600.0
const HIGH_SPEED := 800.0
const BASE_GRAVITY := 3000.0
const LOW_GRAVITY := 2500.0

func get_speed(state: States) -> float:
	match state:
		States.HIGHSPEED: return HIGH_SPEED
	return BASE_SPEED

func get_gravity(state: States) -> float:
	match state:
		States.LOWGRAV: return LOW_GRAVITY
		_: return BASE_GRAVITY

func set_state(new_state: States):
	current_state = new_state

func next_state(current: States) -> States:
	return ((current + 1) % States.size()) as States

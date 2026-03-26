extends MultiplayerSpawner

@export var network_player: PackedScene = preload("res://high_level_example/scenes/player.tscn")

var player_count: int = 0

func _ready() -> void:
	print("Spawner _ready | is_server:", multiplayer.is_server())
	print("network_player assigned:", network_player != null)

	spawn_function = _spawn_player

	if not multiplayer.is_server():
		print("Not server, skipping spawn setup")
		return

	multiplayer.peer_connected.connect(_on_peer_connected)

	player_count += 1
	var spawn_data = {"peer_id": multiplayer.get_unique_id(), "sequential_id": player_count}
	print("Calling spawn() with:", spawn_data)
	var result = spawn(spawn_data)
	print("spawn() returned:", result)

func _on_peer_connected(id: int) -> void:
	print("Peer connected:", id)
	player_count += 1
	var spawn_data = {"peer_id": id, "sequential_id": player_count}
	print("Calling spawn() with:", spawn_data)
	var result = spawn(spawn_data)
	print("spawn() returned:", result)

func _spawn_player(data: Variant) -> Node:
	print("_spawn_player called with:", data)

	if network_player == null:
		push_error("network_player is not assigned!")
		return null

	var player = network_player.instantiate()
	player.sequential_id = data.sequential_id
	player.set_multiplayer_authority(data.peer_id)

	print("Player node created:", player.name, "| authority:", data.peer_id)
	return player

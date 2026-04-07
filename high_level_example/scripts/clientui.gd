extends Control

var isClicked := false

func _on_server_pressed() -> void:
	if isClicked:
		return
	isClicked = true
	HighLevelNetworkHandler.start_server()  # Ensure this is correctly defined elsewhere
	get_tree().change_scene_to_file("res://high_level_example/scenes/S1.tscn")

func _on_client_pressed() -> void:
	if isClicked:
		return
	isClicked = true
	
	

	var mp = get_tree().get_multiplayer()
	mp.connected_to_server.connect(_on_connected_to_server)
	mp.connection_failed.connect(_on_connection_failed)

	HighLevelNetworkHandler.start_client()

func _on_connected_to_server() -> void:
	print("Connected to server")
	get_tree().change_scene_to_file("res://high_level_example/scenes/S1.tscn")

func _on_connection_failed() -> void:
	print("Connection failed")
	isClicked = false
	var mp = get_tree().get_multiplayer()
	if mp.connected_to_server.is_connected(_on_connected_to_server):
		mp.connected_to_server.disconnect(_on_connected_to_server)
	if mp.connection_failed.is_connected(_on_connection_failed):
		mp.connection_failed.disconnect(_on_connection_failed)


func get_player():
	return get_tree().get_first_node_in_group("players")
	
	
func _on_speed_pressed() -> void:
	var player = get_player()
	if player:
		player.set_state(player.states.HIGHSPEED)

func _on_jump_pressed() -> void:
	var player = get_player()
	if player:
		player.set_state(player.states.LOWGRAV)

func _on_slow_pressed() -> void:
	var player = get_player()
	if player:
		player.set_state(player.states.SLOW)

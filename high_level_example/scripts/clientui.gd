extends Control

var isClicked := false

func _on_server_pressed() -> void:
	if isClicked:
		return
	isClicked = true
	HighLevelNetworkHandler.start_server()
	get_tree().change_scene_to_file("res://high_level_example/scenes/high_level_example.tscn")

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
	get_tree().change_scene_to_file("res://high_level_example/scenes/high_level_example.tscn")

func _on_connection_failed() -> void:
	print("Connection failed")
	isClicked = false
	var mp = get_tree().get_multiplayer()
	if mp.connected_to_server.is_connected(_on_connected_to_server):
		mp.connected_to_server.disconnect(_on_connected_to_server)
	if mp.connection_failed.is_connected(_on_connection_failed):
		mp.connection_failed.disconnect(_on_connection_failed)

extends Control

var isClicked = false

func _on_server_pressed() -> void:
	if isClicked == false:
		HighLevelNetworkHandler.start_server()
		isClicked = true


func _on_client_pressed() -> void:
	if isClicked == false:
		HighLevelNetworkHandler.start_client()
		isClicked = true

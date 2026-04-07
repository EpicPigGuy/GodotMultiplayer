extends Node

const PORT: int = 42096
var peer: ENetMultiplayerPeer
var mode

func start_server() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	get_tree().get_multiplayer().multiplayer_peer = peer
	print("Server started on port:", PORT)

func start_client() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_client("localhost", PORT)
	get_tree().get_multiplayer().multiplayer_peer = peer
	print("Client started, connecting to port:", PORT)

func stop() -> void:
	if peer:
		peer.close()
	get_tree().get_multiplayer().multiplayer_peer = null
	peer = null

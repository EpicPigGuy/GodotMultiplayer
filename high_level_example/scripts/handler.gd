extends Node

const PORT: int = 42096 # Below 65535 (16-bit unsigned max value)

var peer: ENetMultiplayerPeer

func start_server() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer


func start_client() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_client("localhost", PORT)
	multiplayer.multiplayer_peer = peer

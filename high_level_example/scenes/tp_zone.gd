extends Area2D

@onready var multiplayer_spawner: MultiplayerSpawner = $"../MultiplayerSpawner"

var triggered: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	# Only server handles it
	if not multiplayer.is_server():
		return
	
	# Already triggered? Do nothing
	if triggered:
		return
	
	# Make sure it's a player
	if not body.has_method("callPlayer"):
		return
	
	triggered = true
	print("Triggered once by:", body.name)
	
	move_all_players.rpc(global_position)


@rpc("authority", "call_local")
func move_all_players(pos: Vector2) -> void:
	var spawn_node = multiplayer_spawner.get_node(multiplayer_spawner.spawn_path)
	
	for player in spawn_node.get_children():
		if player.has_method("callPlayer"):
			player.callPlayer(pos)

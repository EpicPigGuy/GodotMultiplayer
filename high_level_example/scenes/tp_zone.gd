extends Area2D

@onready var multiplayer_spawner: MultiplayerSpawner = $"../MultiplayerSpawner"

var triggered: bool = false
@export var diffPos: bool = false
@export var pos: Vector2 = Vector2(100, 100)

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not multiplayer.is_server():
		return
	if triggered:
		return
	
	if not body.has_method("callPlayer"):
		return
	
	triggered = true
	print("Triggered once by:", body.name)
	
	if !diffPos:
		move_all_players.rpc(global_position)  # or whatever action you want to perform
	else:
		move_all_players.rpc(pos)

@rpc("authority", "call_local")
func move_all_players(pos: Vector2) -> void:
	var spawn_node = multiplayer_spawner.get_node(multiplayer_spawner.spawn_path)
	
	for player in spawn_node.get_children():
		if player.has_method("callPlayer"):
			player.callPlayer(pos)

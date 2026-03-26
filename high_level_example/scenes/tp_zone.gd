extends Area2D

@onready var multiplayer_spawner: MultiplayerSpawner = $"../MultiplayerSpawner"

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if not multiplayer.is_server():
		return
	for player in multiplayer_spawner.get_spawn_node().get_children():
		if player.has_method("callPlayer"):
			player.callPlayer.rpc(position)

extends Node2D


func _ready():
	await get_tree().create_timer(2).timeout
	
	print("=== CLIENT NODE TREE ===")
	print_tree_pretty()

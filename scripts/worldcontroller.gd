extends Node2D

var character_data: Dictionary = {}
var worldScene

func _init() -> void:
	worldScene = preload("res://Scenes/stage_alpha.tscn").instantiate()
	if worldScene:
		add_child(worldScene)
	else:
		print("Error: Failed to load worldScene.")
	
	if has_meta("character_data"):
		character_data = get_meta("character_data")
	
	if character_data:
		print("Received character data:", character_data)
	else:
		print("No character data passed to this scene.")
	var player = preload("res://Scenes/player.tscn").instantiate()
	var enemy = preload("res://Scenes/player2.tscn").instantiate()
	add_child(player)
	add_child(enemy)
	print(worldScene.get_meta("SpawnPlayerOne"))
	print(player.global_position)
	player.global_position = worldScene.get_meta("SpawnPlayerOne")
	enemy.global_position = worldScene.get_meta("SpawnPlayerTwo")

	print(player.global_position)


func _ready() -> void:
	if has_meta("character_data"):
		print("meta in ready")
	pass
	

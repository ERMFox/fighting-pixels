extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pvp_button_up() -> void:
	get_tree().change_scene_to_file("res://Scenes/character_selection.tscn")
	pass # Replace with function body.


func _on_pve_button_up() -> void:
	pass # Replace with function body.


func _on_settings_button_up() -> void:
	pass # Replace with function body.


func _on_quit_button_up() -> void:
	pass # Replace with function body.
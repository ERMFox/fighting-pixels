extends Button

var character_data: Dictionary  # Custom variable for storing character data

func _ready() -> void:
	# If metadata is set, populate the character_data variable
	if has_meta("character_data"):
		character_data = get_meta("character_data")

	# Connect the button press signal to the custom handler
	connect("pressed", Callable(self, "_on_button_pressed"))

func _on_button_pressed() -> void:
	if character_data:
		print("Button pressed for character:", character_data["name"])
		
		# Load the target scene
		var stage_alpha_scene = preload("res://Scenes/world_controller.tscn")
		var stage_alpha_instance = stage_alpha_scene.instantiate()
		stage_alpha_instance.set_meta("character_data", character_data)
		
		# Add the new scene to the tree and remove the current one
		get_tree().root.add_child(stage_alpha_instance)
		get_tree().current_scene.queue_free()
	else:
		print("No character data available!")
 

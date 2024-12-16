extends GridContainer

# Path to characters.json
var characters_path: String

func _init():
	# Load config.json to determine environment
	if FileAccess.file_exists("res://config.json"):
		var file = FileAccess.open("res://config.json", FileAccess.READ)
		if file:
			var content = file.get_as_text()
			var json = JSON.new()
			var error = json.parse(content)
			print(error)
			if error == OK:
				var config = json.parse_string(content)  # Access parsed JSON data
				var env = config.get("env", "prod")  # Default to "prod" if "env" is missing
				# Set characters_path based on environment
				var exe_dir = OS.get_executable_path().get_base_dir()
				characters_path = "res://characters.json" if env == "dev" else exe_dir + "/characters.json"
				print("Environment:", env, "Characters path:", characters_path)
			else:
				print("Failed to parse config.json:", json.get_error_message())
	else:
		print("config.json not found!")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if characters_path:
		load_characters()
	else:
		print("Characters path not set. Cannot load characters.")

# Function to load and process characters.json
func load_characters() -> void:
	if FileAccess.file_exists(characters_path):
		var file = FileAccess.open(characters_path, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			var json = JSON.new()
			var error = json.parse(content)
			if error == OK:
				var characters_data = json.parse_string(content)  # Access parsed JSON data
				create_buttons(characters_data.characters)
			else:
				print("Failed to parse characters.json:", json.get_error_message())
	else:
		print("Characters file not found at:", characters_path)

# Function to dynamically create buttons
# Function to dynamically create buttons
func create_buttons(characters: Array) -> void:
	for character in characters:
		if "icon_location" in character and "name" in character:
			var button = Button.new()
			
			# Set button text and icon
			button.text = character["name"]
			var icon_path = character["icon_location"]
			if FileAccess.file_exists(icon_path):
				var texture = load(icon_path)
				if texture:
					button.icon = texture

			# Attach the custom script to the button
			var button_script = preload("res://scripts/character_button.gd")
			button.set_script(button_script)
			# Set the character data both as metadata and in the script
			button.set_meta("character_data", character)
			print(button.get_script())

			# Add the button to the GridContainer
			add_child(button)
		else:
			print("Character data is missing required fields:", character)

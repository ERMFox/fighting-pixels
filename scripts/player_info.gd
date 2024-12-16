extends Node

var player  # To hold the player node
var health_bar
var stun_bar

func _ready() -> void:
	# Find the correct player node
	player = get_player_node()
	print("Found player node: ", player)

	# Cache references to HealthBar and StunBar
	health_bar = $VBoxContainer/HealthBar
	stun_bar = $VBoxContainer/StunBar
	
	health_bar.min_value = 0
	health_bar.max_value = 100
	
	stun_bar.min_value = 0
	stun_bar.max_value = 100


func _process(delta: float) -> void:
	# Update HealthBar and StunBar dynamically
	health_bar.value = clamp(player.get_health()/2.5, health_bar.min_value, health_bar.max_value)
	stun_bar.value = clamp(player.get_stagger()/2.5, stun_bar.min_value, stun_bar.max_value)

func get_player_node():
	# Get this node's name (Player1Info or Player2Info)
	var my_name = name
	
	# Extract the player number using regex
	var regex = RegEx.new()
	regex.compile(r"\d+")  # Match digits
	var match = regex.search(my_name)
	var number = 1  # Default to 1 if no number is found
	
	if match:
		number = int(match.get_string())
	
	# Determine the player node's name dynamically
	var player_name = "Player" if number == 1 else "Player2"
	
	# Access the player node
	if get_parent().has_node(player_name):
		return get_parent().get_node(player_name)
	
	print("Player node not found: ", player_name)
	return null  # Return null if player node not found

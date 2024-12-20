extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var sprite: AnimatedSprite2D
var weapon_shield: AnimatedSprite2D

# State Tracking
var is_falling: bool = false
var is_landing: bool = false
var facing_direction: Vector2 = Vector2.RIGHT # Default facing direction
var is_blocking: bool = false # Tracks if blocking
var action_locked: bool = false # Prevents attacking/shield bash, but NOT movement
var current_animation: String = "" # Tracks the current animation
var player_prefix: String = "p1_" # Default prefix, overridden by metadata
var weapon_offset: Vector2

var health: float = 100
var stagger: float = 0

var slash_area
var thrust_area
var bash_area
var lock: bool = false
var flipped_right: bool = false
var death_lock: bool = false


func _ready() -> void:
	weapon_offset.y = 15
	sprite = get_child(0) # Player's main sprite
	weapon_shield = get_child(1) # Shared weapon/shield sprite
	reset_weapon_shield()
	slash_area = get_child(1).get_child(0)
	thrust_area = get_child(1).get_child(1)
	bash_area = get_child(1).get_child(2)

	# Fetch player number from metadata
	if has_meta("player_number"):
		var player_number = int(get_meta("player_number"))
		player_prefix = "p%s_" % player_number
		print(player_prefix)
	# Connect the animation_finished signal
	weapon_shield.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	if death_lock:
		return
	if stagger > 0:
		stagger -= 0.5
	if lock:
		if stagger == 0:
			sprite.play("stand_up")
			lock = false
		return
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle falling and landing
	if velocity.y > 0 and not is_on_floor() and not is_falling:
		is_falling = true
		is_landing = true
		sprite.play("Landing", true)

	if is_on_floor() and is_landing:
		is_landing = false
		is_falling = false
		sprite.play("Landing")

	# Idle
	if is_on_floor() and not _is_any_action_pressed() and not is_blocking:
		sprite.play("Idle")

	# Handle jump
	if Input.is_action_just_pressed(player_prefix + "jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		sprite.play("Jump")

	# Handle movement
	var direction := Input.get_axis(player_prefix + "left", player_prefix + "right")
	if direction != 0:
		velocity.x = direction * SPEED
		if is_on_floor() and not is_blocking:
			sprite.play("Running")
		facing_direction = Vector2(direction, 0)
		sprite.flip_h = direction < 0
		if direction > 0 and flipped_right == true:
			weapon_shield.scale.x = -weapon_shield.scale.x
			weapon_shield.flip_h = false
			flipped_right = false
			print("going right")
		elif direction < 0 and not flipped_right:
			weapon_shield.scale.x = -weapon_shield.scale.x
			weapon_shield.flip_h = true
			flipped_right = true
			print("going left")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Handle blocking and bashing
	if Input.is_action_pressed(player_prefix + "block") and not action_locked:
		handle_block()
	elif Input.is_action_just_pressed(player_prefix + "bash") and not action_locked:
		handle_bash()
	else:
		if is_blocking:
			reset_weapon_shield()
		is_blocking = false

	# Handle attacks
	if not is_blocking and not action_locked:
		handle_sword_attack()
	
	move_and_slide()

func handle_sword_attack() -> void:
	# Trigger Light Attack
	if Input.is_action_just_pressed(player_prefix + "light_attack"):
		play_weapon_animation("Light")
		if slash_area is Area2D:
		# Get all overlapping bodies
			var overlapping_bodies = slash_area.get_overlapping_bodies()
		
			for body in overlapping_bodies:
				print("Overlapping body: ", body.name)
				if body.has_method("increase_stagger"):
					body.increase_stagger(40)
				if body.has_method("reduce_health"):
					body.reduce_health(10)

	# Trigger Heavy Attack
	elif Input.is_action_just_pressed(player_prefix + "heavy_attack"):
		play_weapon_animation("Heavy")
		if thrust_area is Area2D:
		# Get all overlapping bodies
			var overlapping_bodies = thrust_area.get_overlapping_bodies()
		
			for body in overlapping_bodies:
				print("Overlapping body: ", body.name)
				if body.has_method("increase_stagger"):
					body.increase_stagger(5)
				if body.has_method("reduce_health"):
					body.reduce_health(15)

func handle_bash() -> void:
	# Trigger Shield Bash
	play_weapon_animation("Special")
	if bash_area is Area2D:
		# Get all overlapping bodies
		var overlapping_bodies = bash_area.get_overlapping_bodies()
		
		for body in overlapping_bodies:
			print("Overlapping body: ", body.name)
			if body.has_method("increase_stagger"):
				body.increase_stagger(75)
			if body.has_method("reduce_health"):
				body.reduce_health(4)

func handle_block() -> void:
	# Trigger Shield Block
	if not is_blocking:
		is_blocking = true
		weapon_shield.play("Defend")

func play_weapon_animation(animation_name: String) -> void:
	# Play an attack or bash animation without locking movement
	action_locked = true
	current_animation = animation_name
	weapon_shield.play(animation_name)


func reset_weapon_shield() -> void:
	# Reset weapon/shield to default state
	print("is ok")
	weapon_shield.play("Default")
	current_animation = ""
	action_locked = false

func _on_animation_finished() -> void:
	# Reset to default when an animation finishes
	if current_animation == "Special" or current_animation == "Heavy" or current_animation == "Light":
		reset_weapon_shield()
		
func _is_any_action_pressed() -> bool:
	return Input.is_action_pressed(player_prefix + "left") or Input.is_action_pressed(player_prefix + "right") or \
		   Input.is_action_pressed(player_prefix + "up") or Input.is_action_pressed(player_prefix + "down") or \
		   Input.is_action_pressed(player_prefix + "light_attack") or Input.is_action_pressed(player_prefix + "heavy_attack") or \
		   Input.is_action_pressed(player_prefix + "jump") or Input.is_action_pressed(player_prefix + "block")

func get_stagger() -> float:
	return stagger

func get_health() -> float:
	return health

func reduce_health(ammount) -> void:
	if is_blocking:
		ammount = ammount/2
	if lock or death_lock:
		return
	health -= ammount
	if health <= 0:
		sprite.play("die")
		death_lock = true
	
func increase_stagger(ammount) -> void:
	if is_blocking:
		ammount = ammount/2
	if lock or death_lock:
		return
	stagger += ammount
	if stagger >= 100:
		lock = true
		sprite.play("faint")

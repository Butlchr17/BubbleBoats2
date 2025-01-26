extends CharacterBody2D

# AI movement settings
@export var speed = 65           # Acceleration speed
@export var rotation_speed = 0.5 # Rotation speed
@export var drag = 0.1           # Base drag to slow down over time
@export var smoothing = 0.03     # Smoothing factor for input blending
@export var max_velocity = 180   # Maximum speed for the AI
@export var follow_delay = 0.02  # Delay (in seconds) before the AI starts following the player

# Reference to the player character
var player

# Flags for range detection and following logic
var player_in_range: bool = false
var player_in_shooting_range: bool = false
var player_in_move_again_area: bool = false  # Flag for MoveAgainArea condition
var can_follow: bool = false  # Flag to indicate if the AI can follow the player

# Timer to handle follow delay
var follow_timer: Timer

# AI movement variables
var target_velocity = Vector2.ZERO  # Desired velocity
var current_velocity = Vector2.ZERO # Current velocity (for momentum)

func _ready():
	# Look for the player node in the scene
	player = get_parent().get_node_or_null("PlayerBoat")  # Replace with the actual path to your player node
	if not player:
		print("Player not found!")
	
	# Create a timer for the follow delay
	follow_timer = Timer.new()
	follow_timer.wait_time = follow_delay
	follow_timer.one_shot = true
	follow_timer.connect("timeout", Callable(self, "_on_follow_timer_timeout"))
	add_child(follow_timer)
	
	# Connect the Area2D signals for the detection zone
	var detection_zone = $DetectionZone
	if detection_zone:
		detection_zone.connect("body_entered", Callable(self, "_on_follow_area_body_entered"))
		detection_zone.connect("body_exited", Callable(self, "_on_follow_area_body_exited"))
	
	# Connect the Area2D signals for the shooting range
	var shooting_range = $ShootingRange
	if shooting_range:
		shooting_range.connect("body_entered", Callable(self, "_on_shoot_area_body_entered"))
		shooting_range.connect("body_exited", Callable(self, "_on_shoot_area_body_exited"))
	
	# Connect the Area2D signals for the MoveAgainArea
	var move_again_area = $MoveAgainArea
	if move_again_area:
		move_again_area.connect("body_entered", Callable(self, "_on_move_again_area_body_entered"))
		move_again_area.connect("body_exited", Callable(self, "_on_move_again_area_body_exited"))

func _physics_process(delta):
	if player and player_in_range and not player_in_shooting_range and not player_in_move_again_area and can_follow:
		print("Player in detection range, moving toward player...")

		# Calculate direction to the player's position (center)
		var direction_to_player = (player.global_position - global_position).normalized()

		# Smoothly rotate towards the player
		var target_rotation = direction_to_player.angle() + (PI / 2)
		rotation = lerp_angle(rotation, target_rotation, rotation_speed * delta)

		# Update target velocity in the AI's forward direction
		target_velocity = Vector2.UP.rotated(rotation) * speed
	else:
		# Stop acceleration when not following
		target_velocity = Vector2.ZERO

	# Apply slippery movement physics
	current_velocity += (target_velocity - current_velocity) * smoothing
	current_velocity -= current_velocity * (drag + 0.05 * current_velocity.length() / max_velocity) * delta

	# Cap the velocity to the maximum value
	if current_velocity.length() > max_velocity:
		current_velocity = current_velocity.normalized() * max_velocity

	# Apply friction on collision
	if is_on_wall():
		current_velocity *= 0.5

	# Assign the smoothed velocity to the AI
	velocity = current_velocity
	move_and_slide()

# Signal handlers for DetectionZone
func _on_follow_area_body_entered(body):
	if body == player:
		player_in_range = true
		can_follow = false
		follow_timer.start()
		print("Player entered detection zone.")

func _on_follow_area_body_exited(body):
	if body == player:
		player_in_range = false
		can_follow = false
		follow_timer.stop()
		print("Player exited detection zone.")

# Signal handlers for ShootingRange
func _on_shoot_area_body_entered(body):
	if body == player:
		player_in_shooting_range = true
		can_follow = false
		print("Player entered shooting range.")

func _on_shoot_area_body_exited(body):
	if body == player:
		player_in_shooting_range = false
		if player_in_range and not player_in_move_again_area:
			follow_timer.start()
		print("Player exited shooting range.")

# Signal handlers for MoveAgainArea
func _on_move_again_area_body_entered(body):
	if body == player:
		player_in_move_again_area = true
		can_follow = false
		print("Player entered MoveAgainArea.")

func _on_move_again_area_body_exited(body):
	if body == player:
		player_in_move_again_area = false
		if player_in_range and not player_in_shooting_range:
			follow_timer.start()
		print("Player exited MoveAgainArea.")

# Timer timeout handler
func _on_follow_timer_timeout():
	can_follow = true
	print("Follow delay finished, AI can now move towards the player.")

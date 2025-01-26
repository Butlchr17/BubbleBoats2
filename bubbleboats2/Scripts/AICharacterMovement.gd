extends CharacterBody2D

# AI movement settings


@export var speed = 65           # Acceleration speed
@export var rotation_speed = 0.5 # Rotation speed
@export var drag = 0.1           # Base drag to slow down over time
@export var smoothing = 0.03     # Smoothing factor for input blending
@export var max_velocity = 180   # Maximum speed for the AI
@export var follow_delay = 0.005  # Delay (in seconds) before the AI starts following the player
@export var shoot_delay = 1.0 	# Delay (in seconds) before the AI can shoot at the player again.

@export var turret_angle_limit = 90.0 # Maximum turret rotation from the boat's forward direction
@export var bullet_scene: PackedScene  # Drag and drop your bullet scene here

# Reference to the player character
var player

# Flags for range detection and following logic
var player_in_range: bool = false
var player_in_shooting_range: bool = false
var player_in_move_again_area: bool = false  # Flag for MoveAgainArea condition
var can_follow: bool = false  # Flag to indicate if the AI can follow the player

# Timer to handle follow delay
var follow_timer: Timer

# Timer to handle shoot delay
var shoot_timer: Timer

# AI movement variables
var target_velocity = Vector2.ZERO  # Desired velocity
var current_velocity = Vector2.ZERO # Current velocity (for momentum)

func _ready():
	# Look for the player node in the scene
	player = get_tree().get_root().get_node("Node2D").get_node("PlayerBoat")  # Replace with the actual path to your player node
	if not player:
		print("Player not found!")
	
	# Create a timer for the follow delay
	follow_timer = Timer.new()
	follow_timer.wait_time = follow_delay
	follow_timer.one_shot = true
	follow_timer.connect("timeout", Callable(self, "_on_follow_timer_timeout"))
	add_child(follow_timer)
	
	shoot_timer = Timer.new()
	shoot_timer.wait_time = shoot_delay
	shoot_timer.one_shot = false
	shoot_timer.connect("timeout", Callable(self, "_on_shoot_timer_timeout"))
	add_child(shoot_timer)	
	#print("ticked")
	
	shoot_timer.start()	
	
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

var deltaC = 0

func _physics_process(delta):
	_tick()
	#deltaC += delta
	#if deltaC >= 1:	
		#deltaC = 0
	
	if player and player_in_range and not player_in_shooting_range and not player_in_move_again_area and can_follow:
		##print("Player in detection range, moving toward player...")

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


func _tick():
	if player_in_range:
		# Turret rotation (aims at the player within the angle limit)
		var relativeAngle = update_turret_rotation()
		
		#if relativeAngle == (player.global_position - global_position).normalized().angle():
		# Turret rotation (aims at the mouse position within the angle limit)
			#shoot()
		
	#shoot_timer = Timer.new()
	#shoot_timer.wait_time = shoot_delay
	#shoot_timer.one_shot = true
	#shoot_timer.connect("timeout", Callable(self, "_on_shoot_timer_timeout"))
	#add_child(shoot_timer)	
	##print("ticked")
	
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

func _on_hitbox_body_entered(body):

	if body.is_in_group("player_bullet"):
		print("Hit!")
		destroy_ai()


# Timer timeout handler
func _on_follow_timer_timeout():
	can_follow = true
	print("Follow delay finished, AI can now move towards the player.")

	# Handle shooting when left mouse button is clicked
	#if player_in_range:
		## Turret rotation (aims at the player within the angle limit)
		#var relativeAngle = update_turret_rotation()
		#
		#if relativeAngle == (player.global_position - global_position).normalized().angle():
		## Turret rotation (aims at the mouse position within the angle limit)
			#shoot()
		#
	#shoot_timer = Timer.new()
	#shoot_timer.wait_time = shoot_delay
	#shoot_timer.one_shot = true
	#shoot_timer.connect("timeout", Callable(self, "_on_shoot_timer_timeout"))
	#add_child(shoot_timer)	

func _on_shoot_timer_timeout():
	print("Follow delay finished, AI can now move towards the player.")
	if player_in_shooting_range:
		shoot()
	
func update_turret_rotation():
	
	#print(player)
	
	# Get the angle to the mouse relative to the turret's position
	var target_angle = (player.global_position - global_position).normalized().angle() 

	# Offset the turret's range by -90 degrees (PI/2 radians counterclockwise)
	var relative_angle = target_angle - (rotation + deg_to_rad(-90))

	# Normalize the relative angle to handle wrapping (between -π and π)
	relative_angle = fmod(relative_angle + PI, PI * 2) - PI

	# Clamp the relative angle within the allowed range
	#relative_angle = clamp(relative_angle, -deg_to_rad(turret_angle_limit), deg_to_rad(turret_angle_limit))

	# Set the turret's rotation relative to the boat, applying the offset back
	$Node2D.rotation = relative_angle + deg_to_rad(90)
	
	return relative_angle
	

func shoot():
	# Ensure the bullet scene is set
	if bullet_scene == null:
		print("Bullet scene not set!")
		return

	# Instantiate the bullet
	var bullet = bullet_scene.instantiate()
	
	bullet.add_to_group("ai_bullet")

	# Set the bullet's position and rotation to match the turret
	bullet.global_position = $Node2D.global_position+ Vector2( 75, 75)
	bullet.rotation = $Node2D.global_rotation + deg_to_rad(180)

	# Add the bullet to the current scene
	get_tree().current_scene.add_child(bullet)


func destroy_ai():
	get_tree().get_root().get_node("Node2D").get_node("PlayerBoat").score += 1
	queue_free()
	

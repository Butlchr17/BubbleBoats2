extends CharacterBody2D

@export var score = 0
@onready var player_health_UI = $Camera2D/PlayerHealth
@onready var scoreboard = $Camera2D/Scoreboard
@onready var game_over_label = $GameOverLabel2
@export var player_health = 5
@export var speed = 100           # Acceleration speed
@export var rotation_speed = 0.5 # Rotation speed
@export var drag = 0.1           # Base drag to slow down over time
@export var smoothing = 0.03     # Smoothing factor for input blending
@export var max_velocity = 180
@export var speed_boost = Vector2.ZERO
   # Maximum speed for the boat
@export var turret_angle_limit = 90.0 # Maximum turret rotation from the boat's forward direction
@export var bullet_scene: PackedScene  # Drag and drop your bullet scene here

var target_velocity = Vector2.ZERO  # Desired velocity
var current_velocity = Vector2.ZERO # Current velocity (for momentum)

func get_input():
	# Handle boat rotation using Left/Right keys
	var target_rotation = rotation + Input.get_axis("Left", "Right") * rotation_speed
	rotation = lerp_angle(rotation, target_rotation, 0.1)  # Gradual steering

	# Move forward/backward based on Up/Down keys
	var input_direction = Input.get_axis("Down", "Up")
	if input_direction != 0:
		target_velocity = (Vector2.UP.rotated(rotation) * input_direction * speed) + speed_boost
		
	else:
		target_velocity = Vector2.ZERO  # No input means no additional force applied

	# Turret rotation (aims at the mouse position within the angle limit)
	update_turret_rotation()

	# Handle shooting when left mouse button is clicked
	if Input.is_action_just_pressed("Fire"):
		shoot()

func update_turret_rotation():
	# Get the angle to the mouse relative to the turret's position
	var target_angle = (get_global_mouse_position() - global_position).angle()

	# Offset the turret's range by -90 degrees (PI/2 radians counterclockwise)
	var relative_angle = target_angle - (rotation - deg_to_rad(90))

	# Normalize the relative angle to handle wrapping (between -π and π)
	relative_angle = fmod(relative_angle + PI, PI * 2) - PI

	# Clamp the relative angle within the allowed range
	relative_angle = clamp(relative_angle, -deg_to_rad(turret_angle_limit), deg_to_rad(turret_angle_limit))

	# Set the turret's rotation relative to the boat, applying the offset back
	$Turret.rotation = relative_angle - deg_to_rad(90)

func shoot():
	# Ensure the bullet scene is set
	if bullet_scene == null:
		print("Bullet scene not set!")
		return

	# Instantiate the bullet
	var bullet = bullet_scene.instantiate()
	bullet.is_player_bullet = true

	bullet.add_to_group("player_bullet")

	# Set the bullet's position and rotation to match the turret
	bullet.global_position = $Turret.global_position + Vector2( 75, 75)
	bullet.rotation = $Turret.global_rotation

	# Add the bullet to the current scene
	get_tree().current_scene.add_child(bullet)

func _physics_process(_delta: float) -> void:
	
	scoreboard.text =  "score: " + str(score)
	
	player_health_UI.text = "Health: " + str(player_health)
	
	get_input()

	# Add momentum by keeping the velocity even when there's no input
	current_velocity += (target_velocity - current_velocity) * smoothing

	# Apply dynamic drag to make the boat slow down gradually
	current_velocity -= current_velocity * (drag + 0.05 * current_velocity.length() / max_velocity) * _delta

	# Cap the velocity to a maximum value
	if current_velocity.length() > max_velocity:
		current_velocity = current_velocity.normalized() * max_velocity

	# Apply friction on collision
	if is_on_wall():
		current_velocity *= 0.5  # Sudden deceleration on collision

	# Assign the final velocity to the built-in velocity property
	velocity = current_velocity

	# Move the boat
	move_and_slide()


func _on_hitbox_player_body_entered(body):
	if body.is_in_group("ai_bullet"):
		print("Hit!")
		player_hit()


func player_hit():
	print("player hit")
	player_health -= 1
	if player_health == 0:
		game_over()


func game_over():
	# Pause the game
	get_tree().paused = true

	# Display the score in the center of the screen
	game_over_label.text = "Game Over! Your Score: " + str(score)
	game_over_label.visible = true

	# Wait for a few seconds before ending the game
	await get_tree().create_timer(3.0).timeout

	# End the game (queue_free or restart logic can go here)
	queue_free()


func _on_terrain_detector_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	pass # Replace with function body.

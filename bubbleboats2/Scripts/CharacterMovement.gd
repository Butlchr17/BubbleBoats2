extends CharacterBody2D

@export var speed = 150           # Acceleration speed
@export var rotation_speed = 0.5 # Rotation speed
@export var drag = 0.1           # Base drag to slow down over time
@export var smoothing = 0.03     # Smoothing factor for input blending
@export var max_velocity = 200   # Maximum speed for the boat
@export var turret_angle_limit = 90.0 # Maximum turret rotation from the boat's forward direction

var target_velocity = Vector2.ZERO  # Desired velocity
var current_velocity = Vector2.ZERO # Current velocity (for momentum)

func get_input():
	# Handle boat rotation using Left/Right keys
	var target_rotation = rotation + Input.get_axis("Left", "Right") * rotation_speed
	rotation = lerp_angle(rotation, target_rotation, 0.1)  # Gradual steering

	# Move forward/backward based on Up/Down keys
	var input_direction = Input.get_axis("Down", "Up")
	if input_direction != 0:
		target_velocity = Vector2.UP.rotated(rotation) * input_direction * speed
	else:
		target_velocity = Vector2.ZERO  # No input means no additional force applied

	# Turret rotation (aims at the mouse position within the angle limit)
	update_turret_rotation()

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

func _physics_process(_delta: float) -> void:
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

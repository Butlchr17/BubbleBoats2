extends CharacterBody2D

@export var speed = 150            # Tank movement speed
@export var rotation_speed = 0.1      # Tank rotation speed
@export var smoothing = 0.2            # Smoothing factor for movement

var target_velocity = Vector2.ZERO     # Desired velocity
var current_velocity = Vector2.ZERO    # Current velocity (for smoothing)

func get_input():
	# Handle tank rotation using Left/Right keys
	rotation += Input.get_axis("Left", "Right") * rotation_speed

	# Move forward/backward based on Up/Down keys
	target_velocity = Vector2.UP.rotated(rotation) * Input.get_axis("Down", "Up") * speed

	# Turret rotation (aims at the mouse position)
	$Turret.look_at(get_global_mouse_position())

func _physics_process(_delta: float) -> void:
	get_input()

	# Smooth the velocity for smoother movement
	current_velocity = current_velocity.lerp(target_velocity, smoothing)

	# Assign the smoothed velocity to the built-in velocity property
	velocity = current_velocity

	# Move the tank
	move_and_slide()

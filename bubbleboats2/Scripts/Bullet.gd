extends RigidBody2D

@export var speed = 250  # Speed of the bullet
@export var is_player_bullet = false

func _ready():
	# Disable gravity for the bullet
	gravity_scale = 0

	# Adjust the direction of the bullet by 90 degrees clockwise
	linear_velocity = Vector2.UP.rotated(rotation + deg_to_rad(90)) * speed

	# Automatically delete the bullet after 2 seconds to avoid clutter
	await get_tree().create_timer(1.0).timeout
	queue_free()

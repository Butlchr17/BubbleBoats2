extends RigidBody2D

@export var speed = 250 # Speed of the bullet
@export var is_player_bullet = false
@export var is_ai_bullet = false

func _ready():
	if is_in_group("ai_bullet"):
		speed -= 75

	# Disable gravity for the bullet
	gravity_scale = 0

	# Adjust the direction of the bullet by 90 degrees clockwise
	linear_velocity = Vector2.UP.rotated(rotation + deg_to_rad(90)) * speed

	# Play the sound immediately
	get_node("AudioStreamPlayer2D").play()

	# Automatically delete the bullet after 1.5 seconds to avoid clutter
	await get_tree().create_timer(1.5).timeout
	queue_free()

extends CharacterBody2D

# Speed of the AI character
@export var move_speed: float = 100

# Reference to the player character
@onready var player = $PlayerBoat

# Flag to check if the player is in range
var player_in_range: bool = false

func _ready():
	# Look for the player node in the scene
	player = get_parent().get_node_or_null("PlayerBoat")  # Replace with the actual path to your player node
	if not player:
		print("Player not found!")
		
	# Connect the Area2D signals (assumes you have an Area2D named "DetectionZone" as a child)
	var detection_zone = $DetectionZone
	if detection_zone:
		detection_zone.connect("body_entered", Callable(self, "_on_follow_area_body_entered"))
		detection_zone.connect("body_exited", Callable(self, "_on_follow_area_body_exited"))

func _physics_process(delta):
	if player and player_in_range:
		print("Player in range, moving toward player...")
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * move_speed
		print("Velocity applied:", velocity)
		move_and_slide()

# Signal handlers for Area2D
func _on_follow_area_body_entered(body):
	if body == player:
		player_in_range = true
		print("Player entered detection zone")

func _on_follow_area_body_exited(body):
	if body == player:
		player_in_range = false
		print("Player exited detection zone")

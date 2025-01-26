extends CharacterBody2D

# Speed of the AI character
@export var move_speed: float = 100

# Reference to the player character
@onready var player = $PlayerBoat

# Flags for range detection
var player_in_range: bool = false
var player_in_shooting_range: bool = false

func _ready():
	# Look for the player node in the scene
	player = get_parent().get_node_or_null("PlayerBoat")  # Replace with the actual path to your player node
	if not player:
		print("Player not found!")
	
	# Connect the Area2D signals for the detection zone
	var detection_zone = $DetectionZone
	if detection_zone:
		detection_zone.connect("body_entered", Callable(self, "_on_follow_area_body_entered"))
		detection_zone.connect("body_exited", Callable(self, "_on_follow_area_body_exited"))
	
	# Connect the Area2D signals for the shooting range
	var shooting_range = $ShootingRange
	if shooting_range:
		shooting_range.connect("body_entered", Callable(self, "_on_shooting_area_body_entered"))
		shooting_range.connect("body_exited", Callable(self, "_on_shooting_area_body_exited"))

func _physics_process(delta):
	# Only move if the player is in detection range but not in shooting range
	if player and player_in_range and not player_in_shooting_range:
		print("Player in detection range, moving toward player...")
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * move_speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO  # Stop moving when the player is in shooting range
		print("Player in shooting range, stopped moving.")

# Signal handlers for DetectionZone
func _on_follow_area_body_entered(body):
	if body == player:
		player_in_range = true
		print("Player entered detection zone")

func _on_follow_area_body_exited(body):
	if body == player:
		player_in_range = false
		print("Player exited detection zone")

# Signal handlers for ShootingRange
func _on_shooting_area_body_entered(body):
	if body == player:
		player_in_shooting_range = true
		print("Player entered shooting range")

func _on_shooting_area_body_exited(body):
	if body == player:
		player_in_shooting_range = false
		print("Player exited shooting range")

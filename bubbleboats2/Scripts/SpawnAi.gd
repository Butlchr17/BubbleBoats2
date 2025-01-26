extends Area2D

@export var ai_prefab: PackedScene  # Drag and drop your AI prefab here
@export var spawn_radius: float = 1  # Radius around the Area2D to spawn AI
@export var spawn_interval: float = 5.0  # Interval in seconds for spawning AI

# Reference to the player's Area2D
@export var player_area: NodePath

var player_area_node: Area2D  # Cached reference to the player's Area2D node

func _ready():
	# Ensure the AI prefab and player Area2D are set
	if not ai_prefab:
		print("AI prefab is not set!")
		return

	player_area_node = get_node_or_null(player_area)
	if not player_area_node:
		print("Player's Area2D node is not set!")
		return

	# Create and configure a Timer node for spawning
	var spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.one_shot = false
	spawn_timer.connect("timeout", Callable(self, "_spawn_ai"))
	add_child(spawn_timer)

	# Start the timer
	spawn_timer.start()

func _spawn_ai():
	if not ai_prefab or not player_area_node:
		return
	for i in randf_range(1, 3):
	# Get a random position around the player's Area2D
		var player_position = player_area_node.global_position
		var random_offset = Vector2(randf_range(-spawn_radius, spawn_radius), randf_range(-spawn_radius, spawn_radius))
		var spawn_position = player_position + random_offset

	# Instantiate the AI prefab
		var ai_instance = ai_prefab.instantiate()
		ai_instance.global_position = spawn_position

	# Add the AI instance to the scene
		get_tree().current_scene.add_child(ai_instance)
	
		print("Spawned AI at:", spawn_position)

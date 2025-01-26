extends CharacterBody2D

@export var speed = 400

func get_input():
	look_at(get_global_mouse_position())
	velocity = transform.x * Input.get_axis("Down", "Up") * speed

func _physics_process(_delta: float) -> void:
	get_input()
	move_and_slide()

extends Area2D

@export_category("Tile Map Properties")
@export var Tilemap: TileMapLayer
@export var terrain_custom_data_name: String = ""
@export var terrain_names = [""] 
#Terrain names will correspond to the number assigned to a tile
#in the assigned custom data
@export var tile_acceleration:int = 200 
var current_tilemaplayer : TileMapLayer
#var current tile
var last_tile_num: int
var coordinates: Vector2i
var resource_coordinates: Vector2i
var collided_tile_coords
var collided_tile_global_coords
var player:CharacterBody2D
var test_bool:bool = true
#functions
func _ready():
	player = get_parent()

func _break_tile() -> void:
	#delete tile
	current_tilemaplayer.set_cell(collided_tile_coords, -1)
	collided_tile_global_coords = current_tilemaplayer.map_to_local(collided_tile_coords)
	print(collided_tile_global_coords)

func _process_tile_collision_enter(body: Node2D, body_rid: RID):
	collided_tile_coords = body.get_coords_for_body_rid(body_rid)
	var tile_data_num = body.get_cell_tile_data(collided_tile_coords).get_custom_data(terrain_custom_data_name)
	var tile_name = terrain_names[tile_data_num]
	#last_tile_name = tile_name
	coordinates = collided_tile_coords
	_do_tile_action_enter(tile_data_num)
	#print(str(tile_name) + "\n" + str(last_tile_name) + "\n" + "------------")
	if(Input.is_physical_key_pressed(KEY_Q)):
		print("You are on " + tile_name + "\n" + str(collided_tile_coords) + "\n" + "-----------------------------------------------" )

func _process_tile_collision_exit(body: Node2D, body_rid: RID):
	collided_tile_coords = body.get_coords_for_body_rid(body_rid)
	var tile_data_num = body.get_cell_tile_data(collided_tile_coords).get_custom_data(terrain_custom_data_name)
	var tile_name = terrain_names[tile_data_num]
	last_tile_num = tile_data_num
	coordinates = collided_tile_coords
	_do_tile_action_exit(tile_data_num)
	

func _do_tile_action_enter(tile_data_num: int):
	match tile_data_num:
		0: #water
			#do nothing
			pass
		1: #boost tile
			player.speed_boost = (player.velocity * tile_acceleration)
		2: #damage tile
			#do damage to player
			_tile_damage(tile_data_num)

func _do_tile_action_exit(tile_data_num: int):
	match tile_data_num:
		0: #water
			#do nothing
			pass
		1: #boost tile
			player.speed_boost = Vector2.ZERO
		2: #damage tile
			
			test_bool = true
			#do nothing
			pass
			
func _tile_damage(tile_data_num: int): 
	if(test_bool == true && tile_data_num != last_tile_num):
		player.player_health -= 1
		test_bool = false
		pass
	#if(last_tile_num != 2):
		#print("-1 health")

#signals

func _on_body_shape_entered(body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body == Tilemap:
		_process_tile_collision_enter(body, body_rid)

func _on_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body == Tilemap:
		_process_tile_collision_exit(body, body_rid)

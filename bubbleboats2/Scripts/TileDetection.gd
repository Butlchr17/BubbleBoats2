extends Area2D

@export_group("Tile Map Properties")
@export var Tilemap: TileMapLayer
@export var terrain_custom_data_name: String = ""
@export var terrain_names = [""] 
#Terrain names will correspond to the number assigned to a tile
#in the assigned custom data

var current_tilemaplayer : TileMapLayer
var last_tile_name: String
var coordinates: Vector2i
var resource_coordinates: Vector2i
var collided_tile_coords
var collided_tile_global_coords

#functions

func _break_tile() -> void:
	#delete tile
	current_tilemaplayer.set_cell(collided_tile_coords, -1)
	collided_tile_global_coords = current_tilemaplayer.map_to_local(collided_tile_coords)
	print(collided_tile_global_coords)

func _process_tile_collision(body: Node2D, body_rid: RID):
	collided_tile_coords = body.get_coords_for_body_rid(body_rid)
	var tile_data_num = body.get_cell_tile_data(collided_tile_coords).get_custom_data(terrain_custom_data_name)
	var tile_name = terrain_names[tile_data_num]
	last_tile_name = tile_name
	coordinates = collided_tile_coords
	if(Input.is_physical_key_pressed(KEY_Q)):
		print("You are on " + tile_name + "\n" + str(collided_tile_coords) + "\n" + "-----------------------------------------------" )

#signals

func _on_body_shape_entered(body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body == Tilemap:
		_process_tile_collision(body, body_rid)

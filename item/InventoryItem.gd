class_name InventoryItem extends Node2D

onready var inventory = load("res://inventory/Inventory.tscn")

var item: Item
var pos: Vector2
var dimension: Vector2 setget , _get_dimension
var rotated: bool setget _set_rotated

func _ready():
	_set_rotated(rotated)
	pass

func _init(item: Item, pos: Vector2, rotated: bool):
	self.item = item
	self.pos = pos
	self.rotated = rotated
	pass

func _get_dimension():
	if(!rotated):
		return item.dimension
	return Vector2(item.dimension.y, item.dimension.x)
	
func _set_rotated(is_rotated: bool):
	var slot_size_vector = Vector2(Shared.SLOT_SIZE, Shared.SLOT_SIZE)
	var size = slot_size_vector * _get_dimension()
	item._get_item_texture()._set_min_size(Vector2(size.x if is_rotated else size.y, size.x if !is_rotated else size.y))

func _get_item_texture():
	return item._get_item_texture()

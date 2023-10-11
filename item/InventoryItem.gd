class_name InventoryItem extends Node2D

var inventory = load("res://inventory/Inventory.tscn")
var item: Item
var pos: Vector2
var dimension: Vector2 setget , _get_dimension
var rotated: bool setget _set_rotated
onready var slot_size: int = $SlotGrid._get_slot_size

func _ready():
	_set_rotated(rotated)
	pass

func _init(item: Item = null, pos: Vector2 = Vector2(0, 0), rotated: bool = false):
	self.item = item
	self.pos = pos
	self.rotated = rotated
	pass

func _get_dimension():
	if(!rotated):
		return item.dimension
	return Vector2(item.dimension.y, item.dimension.x)
	
func _set_rotated(is_rotated: bool):
	var width = slot_size * dimension.x
	var height = slot_size * dimension.y
	item.ItemTexture.rect_size.x = width if is_rotated else height
	item.ItemTexture.rect_size.y = width if !is_rotated else height

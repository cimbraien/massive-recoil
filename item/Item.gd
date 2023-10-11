class_name Item extends Node2D

var dimension : Vector2
var texture: ItemTexture setget , _get_item_texture

func _init(dimension: Vector2, texturePath: String = ""):
	self.dimension = dimension
	self.texture = ItemTexture.new(texturePath)
	pass

func _get_item_texture():
	return texture

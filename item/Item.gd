class_name Item extends Node2D

var dimension : Vector2 = Vector2(0, 0)
var texture: ItemTexture = null

func _init(dimension: Vector2 = Vector2(0, 0), texturePath: String = ""):
	self.dimension = dimension
	self.texture = ItemTexture.new(texturePath)
	pass

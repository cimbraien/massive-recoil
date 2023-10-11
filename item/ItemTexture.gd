class_name ItemTexture extends TextureRect

func _ready():
	pass

func _init(texturePath: String = ""):
	texture = load(texturePath)

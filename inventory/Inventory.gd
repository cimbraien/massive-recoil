class_name Inventory extends Node

onready var gui: TextureRect = $InventoryGUI
onready var toggleAnimation = $InventoryGUI/Toggle
var inventory_items : Array

func _ready():
	gui.visible = false
	var radarItem = Item.new(Vector2(1, 1), "res://item/textures/Radar.png")
	var radarInventoryItem = InventoryItem.new(radarItem)
	inventory_items.append(radarInventoryItem)
	return

func _init():
	inventory_items = []
	return

func _input(event):
	if event.is_action_pressed("inventory_toggle"):
		if gui.visible:
			_closeGui()
		else:
			_openGui()

func _render_items():
	for items in inventory_items:
		add_child(items)

func _openGui():
	$InventoryGUI/ToggleOn.play()
	gui.visible = true
	toggleAnimation.play("open")
	_render_items()
	
func _closeGui():
	$InventoryGUI/ToggleOff.play()
	toggleAnimation.play("close")
	yield(toggleAnimation, "animation_finished")
	gui.visible = false

class_name Inventory extends Node

onready var gui: TextureRect = $InventoryGUI
onready var toggleAnimation = $InventoryGUI/Toggle
var inventory_items : Array

func _ready():
	gui.visible = false
	return

func _init():
	inventory_items = []
	var snowball = InventoryItemFactory.new("SNOWBALL", Vector2(3,2))._build()
	var snowball2 = InventoryItemFactory.new("SNOWBALL", Vector2(1,3))._build()
	var snowball3 = InventoryItemFactory.new("SNOWBALL", Vector2(6,1))._build()
	inventory_items.append(snowball)
	inventory_items.append(snowball2)
	inventory_items.append(snowball3)
	return

func _input(event):
	if event.is_action_pressed("inventory_toggle"):
		if gui.visible:
			_closeGui()
		else:
			_openGui()

func _render_items():
	for item in inventory_items:
		var slot: Slot = $InventoryGUI/SlotGrid._get_slot(item.pos.x, item.pos.y)
		var container = _create_item_container()
		container.add_child(item._get_item_texture())
		slot.add_child(container)

func _create_item_container():
	var container = CenterContainer.new();
	return container

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

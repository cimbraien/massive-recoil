extends Sprite


onready var animator: AnimationPlayer = $"%AnimationPlayer"
onready var sprite: Sprite = $"%Sprite"
onready var hurtbox: Area2D = $"%Hurtbox"

const DEBRIS: PackedScene = preload("res://enemies/Debris.tscn")

export var health: int = 1
export var upside_down: bool = false

onready var hit: AudioStreamPlayer = $"%Hit"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass


func _on_Hurtbox_ouch(damage, pos) -> void:
	hit.play()
	health -= damage
	if health <= 0:
		Shared.camera.animator.play("Shake")
		var hit_position: float = pos.y - hurtbox.global_position.y
		if rotation_degrees == 0:
			if hit_position < -10:
				sprite.frame = 1
			elif hit_position > 10:
				sprite.frame = 2
			else:
				sprite.frame = 3
		elif upside_down == true:
			if hit_position > -10:
				sprite.frame = 1
			elif hit_position < 10:
				sprite.frame = 2
			else:
				sprite.frame = 3
		hurtbox.set_collision_layer_bit(1, false)
		# debris
		var debris: Node2D = DEBRIS.instance()
		Shared.tree.current_scene.add_child(debris)
		debris.global_position = sprite.global_position
	else:
		animator.stop(true)
		animator.play("Ouch")


func _on_Hurtbox_area_entered(area: Area2D) -> void:
	print(area)

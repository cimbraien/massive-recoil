extends AnimatedSprite


func _ready() -> void:
	play("default")


func _on_Dust_animation_finished() -> void:
	queue_free()

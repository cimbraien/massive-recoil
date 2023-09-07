extends Sprite


func _ready() -> void:
	var tw: = create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.5)  # warning-ignore-all:return_value_discarded
	tw.tween_callback(self, "queue_free")

extends RigidBody2D


onready var shell_bounce_sfx: AudioStreamPlayer = $"%ShellBounce"


func _on_BulletShell_body_entered(_body: Node) -> void:
	shell_bounce_sfx.play()

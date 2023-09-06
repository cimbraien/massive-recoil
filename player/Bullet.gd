extends Sprite

const BULLETHIT: PackedScene = preload("res://player/BulletHit.tscn")

onready var ray: RayCast2D = $"%RayCast2D"
onready var line: Line2D = $"%Line2D"

const SPEED: float = 2160.0
var velocity: Vector2 = Vector2(SPEED, 0)

var line_points: Array = []
var max_points: int = 5
var frame_no: int = 0


func _ready() -> void:
	line.set_as_toplevel(true)
	visible = false


func _process(delta: float) -> void:
	# hide on 1st frame
	if frame_no == 1:
		visible = true
	else:
		frame_no += 1
	# wait for cam
	if not Shared.camera:
		return
	# cam rect
	var cam_rect: Rect2 = Rect2(Shared.camera.get_camera_screen_center() - get_viewport_rect().size / 2, get_viewport_rect().size)
	# move
	global_position += velocity * delta
	global_position.x = clamp(global_position.x, cam_rect.position.x, cam_rect.position.x + cam_rect.size.x)
	global_position.y = clamp(global_position.y, cam_rect.position.y, cam_rect.position.y + cam_rect.size.y)
	# at boundary
	if global_position.x <= cam_rect.position.x \
	or global_position.x >= cam_rect.position.x + cam_rect.size.x \
	or global_position.y <= cam_rect.position.y \
	or global_position.y >= cam_rect.position.y + cam_rect.size.y:
		queue_free()
	# hit world
	if ray.is_colliding():
		global_position = ray.get_collision_point()
		queue_free()
		# smoke
		var bullet_hit = BULLETHIT.instance() as Particles2D
		Shared.tree.current_scene.add_child(bullet_hit)
		bullet_hit.global_position = ray.get_collision_point()
		bullet_hit.rotation = ray.get_collision_normal().angle()
	# line
	line.add_point(global_position)
	while line.get_point_count() > max_points:
		line.remove_point(0)

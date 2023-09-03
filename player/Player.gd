extends KinematicBody2D


onready var sprite: Sprite = $"%Sprite"
onready var animator: AnimationPlayer = $"%AnimationPlayer"
onready var aim_origin: Position2D = $"%AimOrigin"

const MAX_RUN: float = 180.0
const MAX_FALL: float = 540.0
const H_WEIGHT: float = 0.2
const JUMP_VEL: float = -461.893764
const GRAVITY: float = 1066.729248

var direction: int = 0
var state: int = 0 setget set_state
var velocity: Vector2 = Vector2.ZERO
var old_sprite_scale_x: int = 1


func _ready() -> void:
	animator.play("Idle")


func _physics_process(delta: float) -> void:
	# gravity
	velocity.y += GRAVITY * delta
	velocity.y = min(velocity.y, MAX_FALL)
	
	# update horizontal vel
	velocity.x = lerp(velocity.x, direction * MAX_RUN, H_WEIGHT)
	
	# move
	velocity = move_and_slide(velocity, Vector2.UP)
	
	# update scale x
	old_sprite_scale_x = int(sprite.scale.x)
	if direction != 0:
		sprite.scale.x = direction
	
	# horizontal input
	direction = int(Input.get_axis("left", "right"))
	
	# handle state
	# idle
	if state == 0:
		# to fall
		if not is_on_floor():
			self.state = 2
		# to run
		elif direction != 0:
			self.state = 1
		# jump
		elif Input.is_action_just_pressed("jump"):
			self.state = 3
		# aim
		elif Input.is_action_pressed("aim"):
			self.state = 4
			
		# take aim
	# run
	elif state == 1:
		# in state
		# turn
		if old_sprite_scale_x != sprite.scale.x:
			animator.play("Turn")
		# to fall
		if not is_on_floor():
			self.state = 2
		# to run
		elif direction == 0:
			self.state = 0
		# jump
		elif Input.is_action_just_pressed("jump"):
			self.state = 3
		# aim
		elif Input.is_action_pressed("aim"):
			self.state = 4
	# fall
	elif state == 2:
		# to idle
		if is_on_floor() and direction == 0:
			self.state = 0
		# to run
		elif is_on_floor() and direction != 0:
			self.state = 1
	# rise
	elif state == 3:
		# in state
		# jump cancel
		if not Input.is_action_pressed("jump"):
			velocity.y += GRAVITY * delta
		# to idle
		if is_on_floor() and direction == 0:
			self.state = 0
		# to run
		elif is_on_floor() and direction != 0:
			self.state = 1
		# to fall
		elif velocity.y > 0:
			self.state = 2
	# aim
	elif state == 4:
		# in state
		var relative_mouse_position: Vector2 = aim_origin.get_local_mouse_position()
		# flip sprite based on mouse pos
		if sign(relative_mouse_position.x) != 0:
			sprite.scale.x = sign(relative_mouse_position.x)
		# update frame
		# turn angle to respect the positive Y axis, or (0, 1) vector, in radians.
		var angle_to_positive_y = atan2(relative_mouse_position.x, -relative_mouse_position.y)
		# to deg
		var angle_in_degrees = rad2deg(angle_to_positive_y)
		# covert to frame index
		var frame_index = abs(int(angle_in_degrees / 13)) + 30
		sprite.frame = frame_index
		# to fall
		if not is_on_floor():
			self.state = 2
		# aim
		elif not Input.is_action_pressed("aim"):
			# to idle
			if direction == 0:
				self.state = 0
			# to run
			elif direction != 0:
				self.state = 1
		# cannot move
		direction = 0


func set_state(value):
	var old_state = state
	state = value
	
	# jump
	if state == 3:
		velocity.y = JUMP_VEL
	
	# update anim
	# idle
	if state == 0:
		if old_state == 4:
			animator.play("AimToIdle")
		else:
			animator.play("ToIdle")
	# run
	elif state == 1:
		# turn
		if old_sprite_scale_x != sprite.scale.x:
			animator.play("Turn")
		elif old_sprite_scale_x == sprite.scale.x:
			animator.play("ToRun")
	# fall
	elif state == 2:
		animator.play("ToFall")
	# rise
	elif state == 3:
		animator.play("Rise")
	# aim
	elif state == 4:
		animator.stop()


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	# handle transition anim
	if anim_name == "ToRun":
		animator.play("Run")
	elif anim_name == "ToIdle" or anim_name == "AimToIdle":
		animator.play("Idle")
	elif anim_name == "ToFall":
		animator.play("Fall")
	elif anim_name == "Turn":
		animator.play("Run")

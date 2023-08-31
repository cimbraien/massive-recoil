extends KinematicBody2D


onready var sprite: Sprite = $"%Sprite"
onready var animator: AnimationPlayer = $"%AnimationPlayer"

const MAX_RUN: float = 180.0
const MAX_FALL: float = 540.0
const H_WEIGHT: float = 0.2
const JUMP_VEL: float = -461.893764
const GRAVITY: float = 1066.729248

var state = 0 setget set_state
var velocity: Vector2 = Vector2.ZERO
var old_sprite_scale_x: int = 1


func _ready() -> void:
	animator.play("Idle")


func _physics_process(delta: float) -> void:
	# gravity
	velocity.y += GRAVITY * delta
	velocity.y = min(velocity.y, MAX_FALL)
	
	# move
	velocity = move_and_slide(velocity, Vector2.UP)
	
	# horizontal input
	var direction: int = Input.get_axis("ui_left", "ui_right")
	
	# update horizontal vel
	velocity.x = lerp(velocity.x, direction * MAX_RUN, H_WEIGHT)
	
	# update scale x
	old_sprite_scale_x = sprite.scale.x
	sprite.scale.x = direction if direction != 0 else sprite.scale.x
	
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
		elif Input.is_action_just_pressed("ui_up"):
			self.state = 3
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
		elif Input.is_action_just_pressed("ui_up"):
			self.state = 3
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
		if not Input.is_action_pressed("ui_up"):
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


func set_state(value):
	state = value
	
	# jump
	if state == 3:
		velocity.y = JUMP_VEL
	
	# update anim
	# idle
	if state == 0:
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


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	# handle transition anim
	if anim_name == "ToRun":
		animator.play("Run")
	elif anim_name == "ToIdle":
		animator.play("Idle")
	elif anim_name == "ToFall":
		animator.play("Fall")
	elif anim_name == "Turn":
		animator.play("Run")

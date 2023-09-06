extends KinematicBody2D


const BULLETSCENE: PackedScene = preload("res://player/Bullet.tscn")
const MUZZLEFLASH: PackedScene = preload("res://player/MuzzleFlash.tscn")
const BULLETSHELL: PackedScene = preload("res://player/BulletShell.tscn")

onready var sprite: Sprite = $"%Sprite"
onready var sprite_2: Sprite = $"%Sprite2"  # fire 1st frame (hidden)
onready var sprite_3: Sprite = $"%Sprite3"  # fire 2nd frame (hidden)
onready var animator: AnimationPlayer = $"%AnimationPlayer"
onready var aim_origin: Position2D = $"%AimOrigin"
onready var handgun_fire: AudioStreamPlayer = $"%Handgun"
onready var land: AudioStreamPlayer = $"%Land"

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
			land.play()
		# to run
		elif is_on_floor() and direction != 0:
			self.state = 1
			land.play()
	# rise
	elif state == 3:
		# in state
		# jump cancel
		if not Input.is_action_pressed("jump"):
			velocity.y += GRAVITY * delta
		# to idle
		if is_on_floor() and direction == 0:
			self.state = 0
			land.play()
		# to run
		elif is_on_floor() and direction != 0:
			self.state = 1
			land.play()
		# to fall
		elif velocity.y > 0:
			self.state = 2
	# aim
	elif state == 4:
		# in state
		var relative_mouse_position: Vector2 = aim_origin.get_local_mouse_position()
		# flip sprite based on mouse pos
		var rel_mouse_pos_x_sign: int = int(sign(relative_mouse_position.x))
		if sign(relative_mouse_position.x) != 0:
			sprite.scale.x = rel_mouse_pos_x_sign
			sprite_2.scale.x = rel_mouse_pos_x_sign
			sprite_3.scale.x = rel_mouse_pos_x_sign
		# update frame
		# turn angle to respect the positive Y axis, or (0, 1) vector, in radians.
		var angle_to_positive_y = atan2(relative_mouse_position.x, -relative_mouse_position.y)
		# to deg
		var angle_in_degrees = rad2deg(angle_to_positive_y)
		# covert to frame index
		var frame_index = abs(int(angle_in_degrees / 13)) + 30
		sprite.frame = frame_index
		sprite_2.frame = frame_index + 14
		sprite_3.frame = frame_index + 28
		
		# fire
		if Input.is_action_just_pressed("fire"):
			animator.play("Fire")
			# bullet
			var bullet: Sprite = BULLETSCENE.instance()
			Shared.tree.current_scene.add_child(bullet)
			bullet.global_position = aim_origin.global_position
			bullet.velocity = bullet.velocity.rotated(relative_mouse_position.angle())
			bullet.rotation = bullet.velocity.angle()
			# muzzle flash
			var muzzle_flash: Node2D = MUZZLEFLASH.instance()
			Shared.tree.current_scene.add_child(muzzle_flash)
			muzzle_flash.global_position = aim_origin.global_position
			muzzle_flash.rotation = bullet.velocity.angle()
			# bullet shell
			var bullet_shell: Node2D = BULLETSHELL.instance()
			Shared.tree.current_scene.add_child(bullet_shell)
			bullet_shell.global_position = aim_origin.global_position
			bullet_shell.linear_velocity.x *= rel_mouse_pos_x_sign
			bullet_shell.angular_velocity *= rel_mouse_pos_x_sign
			bullet_shell.linear_velocity.x *= rand_range(0.75, 1.25)
			bullet_shell.angular_velocity *= rand_range(0.75, 1.25)
			bullet_shell.scale.x = rel_mouse_pos_x_sign
			# sfx
			handgun_fire.play()
		# to fall
		if not is_on_floor():
			animator.stop()
			sprite.visible = true
			sprite_2.visible = false
			sprite_3.visible = false
			self.state = 2
		# aim
		elif not Input.is_action_pressed("aim"):
			animator.stop()
			sprite.visible = true
			sprite_2.visible = false
			sprite_3.visible = false
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

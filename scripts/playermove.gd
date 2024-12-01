class_name PlayerMove
extends CharacterBody3D

enum PlayerMovementState {
	IMMOBILE,
	GROUNDED_WALK,
	JUMP
}

const WALK_SPEED : float = 7.0
const SPRINT_SPEED : float = 8.0
const JUMP_VELOCITY : float = 10
const AIR_ACCEL_MULTIPLIER : float = 0.7
const SHORT_HOP_MULTIPLIER : float = 0.6
const MOVE_ACCEL : float = 0.7

var speed : float = WALK_SPEED
var gravity : float = 26

var _input_direction: Vector2

var jump_pressed : bool = false
var currently_jumping : bool = false

var movement_state : PlayerMovementState = PlayerMovementState.GROUNDED_WALK

func _unhandled_input(_event):
	# TODO - move to _process as this is just polling (we are not reacting to inputs dynamically)
	_input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	jump_pressed = Input.is_action_just_pressed("jump")
	
	if Input.is_action_just_released("jump") and currently_jumping and velocity.y > 0:
		velocity.y *= SHORT_HOP_MULTIPLIER

func _physics_process(delta: float) -> void:
	# GRAVITY
	var used_acceleration = MOVE_ACCEL

	if not is_on_floor():
		velocity.y -= gravity * delta
	elif currently_jumping:
		currently_jumping = false

	# JUMPING
	if is_on_floor() and jump_pressed and !currently_jumping:
		velocity.y = JUMP_VELOCITY
		currently_jumping = true

	var direction = (transform.basis * Vector3(_input_direction.x, 0, _input_direction.y))
	var mvel = velocity.move_toward(speed * direction, used_acceleration)
	velocity.x = mvel.x
	velocity.z = mvel.z

	move_and_slide()

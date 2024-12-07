class_name PlayerCamera
extends Camera3D

var look_m_sense : float = 0.1
var look_c_sense : float = 3

var target_recoil : Vector3 = Vector3.ZERO

var should_reset_recoil : bool = false ## If true, should gradually interpolate to reset_state
var reset_state : Vector3 = Vector3.ZERO ## The rotation to go back to once firing recoil is done. Stored in radians (i.e. transform.rotation)
var _recoil_reset_delay_timer : float ## Timer until we start to recover from recoil 

var root : Node3D

const RECOIL_RECOVERY_START_TIME : float = 0.2

func _ready() -> void:
	root = get_parent_node_3d()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		root.rotate_y(deg_to_rad(-event.relative.x * look_m_sense))
		rotate_x(deg_to_rad(-event.relative.y * look_m_sense))
		rotation.x = clamp(rotation.x, deg_to_rad(-85), deg_to_rad(85))
		if event.relative.y != 0:
			should_reset_recoil = false
			
	if Input.is_key_pressed(KEY_ESCAPE):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(delta: float) -> void:
	#global_rotate(Vector3.AXIS_X,Input.get_axis("look_m_v_up","look_m_v_down"))
	var input_vec : Vector2 = Input.get_vector("look_left","look_right","look_up","look_down")
	root.rotate_y(deg_to_rad(-input_vec.x * look_c_sense))
	rotate_x(deg_to_rad(-input_vec.y * look_c_sense))
	rotation.x = clamp(rotation.x, deg_to_rad(-85), deg_to_rad(85))
	if input_vec.y != 0:
		should_reset_recoil = false

	target_recoil = lerp(target_recoil, Vector3.ZERO, delta * 25)
	if _recoil_reset_delay_timer > 0:
		_recoil_reset_delay_timer -= delta
	if _recoil_reset_delay_timer <= 0 and should_reset_recoil:
		# Reset Recoil Here
		if abs(rotation.x - reset_state.x) < 0.0005:
			rotation.x = reset_state.x
			should_reset_recoil = false
		else:
			rotation.x = lerpf(rotation.x,reset_state.x, delta * 4)
	else:
		# Keep applying recoil
		rotation.x += target_recoil.x * 0.01
		root.rotation.y += target_recoil.y * 0.01
	rotation.x = clamp(rotation.x, deg_to_rad(-85), deg_to_rad(85))

func add_recoil(camera_recoil_ammount_vertical: float, camera_recoil_variability_horizontal: float) -> void:
	var add_rot = Vector3(camera_recoil_ammount_vertical,randf_range(-camera_recoil_variability_horizontal,camera_recoil_variability_horizontal),0)
	target_recoil += add_rot
	#reset_target_recoil -= add_rot
	
	if _recoil_reset_delay_timer <= 0 or not should_reset_recoil:
		should_reset_recoil = true
		reset_state = rotation
	_recoil_reset_delay_timer = RECOIL_RECOVERY_START_TIME
	return

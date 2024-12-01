class_name PlayerCamera
extends Camera3D

var look_m_sense : float = 0.1
var look_c_sense : float = 3

var root : Node3D

func _ready() -> void:
	root = get_parent_node_3d()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		root.rotate_y(deg_to_rad(-event.relative.x * look_m_sense))
		rotate_x(deg_to_rad(-event.relative.y * look_m_sense))
		rotation.x = clamp(rotation.x, deg_to_rad(-85), deg_to_rad(85))
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

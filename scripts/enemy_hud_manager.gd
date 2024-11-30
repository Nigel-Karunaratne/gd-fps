extends Node3D

@export var active_enemy_ref : BaseEnemy
var queued_enemy_ref : BaseEnemy
var switch_delay_timer : float = 0
@export var health_bar : ProgressBar

var detection_zone: ShapeCast3D

# There is only ONE healthbar active at a time
func _ready() -> void:
	detection_zone = ShapeCast3D.new()
	detection_zone.debug_shape_custom_color = Color(1,0,0)
	var detection_shape:CylinderShape3D = CylinderShape3D.new()
	detection_shape.radius = 0.5
	detection_shape.height = 30
	detection_zone.target_position.y = -(detection_shape.height / 2)
	detection_zone.max_results = 1
	detection_zone.shape = detection_shape
	detection_zone.exclude_parent = true
	detection_zone.rotation_degrees.x = 90
	detection_zone.collision_mask = 2
	get_viewport().get_camera_3d().add_child(detection_zone)
	
	queued_enemy_ref = null
	return
	
func _process(delta: float) -> void:
	if detection_zone.is_colliding():
		var closest_enemy = detection_zone.get_collider(0)
		if closest_enemy is EnemyHitBoxBase and closest_enemy.get_enemy() != active_enemy_ref:
			queued_enemy_ref = closest_enemy.get_enemy()
	else:
		active_enemy_ref = null
		
	if switch_delay_timer > 0:
		switch_delay_timer -= delta
	if switch_delay_timer <= 0 and queued_enemy_ref != null:
		_change_queued_to_active()
		switch_delay_timer = 0.5

	if is_instance_valid(active_enemy_ref):
		health_bar.visible = not get_viewport().get_camera_3d().is_position_behind(active_enemy_ref.global_position + Vector3(0,1,0))
		var vertical_offset_y = 0.75 + (get_viewport().get_camera_3d().global_position - active_enemy_ref.global_position).length() / 15 # The further away the player is, the higher up the health bar should go
		health_bar.position = get_viewport().get_camera_3d().unproject_position(active_enemy_ref.global_position + Vector3(0,vertical_offset_y,0)) + Vector2(-111,0) #131.5 = health_bar.size.x/2
		health_bar.value = active_enemy_ref.health
	elif health_bar.visible:
		health_bar.visible = false

func change_health_bar_target(new_enemy: BaseEnemy) -> bool:
	if switch_delay_timer <= 0:
		queued_enemy_ref = new_enemy
		_change_queued_to_active()
		switch_delay_timer = 0.5
		return true
	else:
		queued_enemy_ref = new_enemy
		return false

func _change_queued_to_active() -> void:
	active_enemy_ref = queued_enemy_ref
	queued_enemy_ref = null
	health_bar.max_value = active_enemy_ref.max_health

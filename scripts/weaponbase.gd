extends Node3D

enum ProjectileType {RAYCAST, OBJECT}

@export_category("Damage")
@export var damage_type : ProjectileType = ProjectileType.RAYCAST
@export var per_shot_damage : int      ## the damage, per bullet (NOT necessarily per shot), of a weapon
@export var critical_damage_multiplier : float ## The multiplier for critical hits

@export_category("Range")
@export var base_range : float         ## the maximum distance (in m) the bullet can be fired before experiencing damage falloff (raycast)
@export var base_range_max : float     ## the maximum distance (in m) a bullet can travel before dying out (raycast)
@export var bullets_per_shot : int = 1 ## the number of bullets per pull of the trigger (per shot)

@export_category("Ammunition")
@export var base_mag_size : int    ## how many times you can fire a gun before needing to reloading
@export var base_inventory_count : int  ## how many magazines a player has. total shots = base_mag_size * inventory_count
var current_mag_size : int
var current_mag_count : int
var current_reserve_count : int # inventory_count * mag_size, represents number of shots

@export_category("Firing")
@export var is_automatic : bool    ## is this weapon full auto or semi-auto?

@export var default_accuracy_cone_radius : float ##
@export var max_bloom_cone_radius : float        ## The maximum bloom ammount
@export var bloom_increase_per_pull : float      ## The increase in bloom per shot fired
@export var bloom_decrease_scalar : float        ## The constant decrease in bloom per second. The higher it is, the faster bloom resets.
var _current_bloom : float                       ## The current bloom to use when firing

@export var damage_fallof_curve : Curve2D

@export var camera_recoil_ammount_vertical : float ## The ammount of fixed vertical movement done by the camera per shot. Keep low
@export var camera_recoil_variability_horizontal : float ## The ammount of variable horizontal movement done by the camera per shot. Keep *very* low

@export_category("Reloading")
@export var reload_time : float               ## How long, in seconds, to reload
@export var reload_time_scalar : float = 1.0  ## Multiplier for reload time (for perks)
var _reloading_timer : float # if <= 0, not reloading

@export var firing_delay : float  ## how long it is between shots
var _current_firing_delay : float ## timer for firing delay. <= 0 means can fire

## WEAPON PERKS
var perk_count : int          ## The number of available perk slots on this weapon
var perks : Array[WeaponPerk] ## The perks on this weapon

func _ready() -> void:
	# TODO - move to a factory method?
	_current_firing_delay = firing_delay
	current_mag_size = base_mag_size
	current_mag_count = base_mag_size # Fully loaded
	current_reserve_count = base_inventory_count * current_mag_size

func _process(delta: float) -> void:
	# Handle Weapon Timers
	if _current_firing_delay > 0:
		_current_firing_delay -= delta
	if _reloading_timer > 0:
		_reloading_timer -= delta
		if _reloading_timer <= 0:
			# Finished reloading
			current_mag_count = current_mag_size
	
	if _current_bloom > 0:
		_current_bloom -= delta * bloom_decrease_scalar
	#print(_current_bloom)
	
	# Get Input
	if Input.is_action_just_pressed("reload"):
		reload_weapon()
	
	if is_automatic and Input.is_action_pressed("fire"):
		fire_weapon()
	elif Input.is_action_just_pressed("fire"):
		fire_weapon()

func reload_weapon() -> void:
	if current_mag_count >= current_mag_size:
		return
	if _reloading_timer <= 0:
		print("start reload")
		_reloading_timer = reload_time * reload_time_scalar
	pass

# Fires the weapon, if possible. Returns true if successful (the weapon was fired).
func fire_weapon() -> bool:
	if _current_firing_delay <= 0 and _reloading_timer <= 0 and current_mag_count > 0:
		_current_firing_delay = firing_delay
	else:
		return false
	current_mag_count -= 1
	match damage_type:
		ProjectileType.RAYCAST:
			var space = get_world_3d().direct_space_state
			var ray_end: Vector3 = get_parent().global_position  + (global_basis * Vector3(randf_range(-_current_bloom * 0.1,_current_bloom* 0.1),randf_range(-_current_bloom * 0.1,_current_bloom* 0.1),-base_range))
			#var ray_end: Vector3 = get_parent().global_position  + (global_basis * Vector3(0,0,-base_range))
			var query = PhysicsRayQueryParameters3D.create(get_parent().global_position, ray_end)
#			# TODO - make bloom not vary w/ range!
			query.exclude = [self]
			var result = space.intersect_ray(query)
			if !result.is_empty(): # hit
				if result.collider is EnemyHitBoxBase: # hit enemy
					(result.collider as EnemyHitBoxBase).on_hit(per_shot_damage, critical_damage_multiplier)
				else: # hit a wall or something, add a decal
					EventBus.s_deploydecal.emit(result.position, result.normal)
				#var b=load("res://prefabs/anchor.tscn").instantiate()
				#get_tree().current_scene.add_child(b)
				#b.global_position = get_parent().global_position  + (global_basis * Vector3(0,0,-base_range))
				#b.global_position = get_parent().global_transform.origin + (Vector3.FORWARD * base_range)
			pass
		ProjectileType.OBJECT:
			pass
		_:
			push_error("ProjectileType on a WeaponBase is undefined, and firing was attempted")
			pass
	_current_bloom = min(_current_bloom + bloom_increase_per_pull, max_bloom_cone_radius)
	(get_viewport().get_camera_3d() as PlayerCamera).add_recoil(camera_recoil_ammount_vertical/10, camera_recoil_variability_horizontal/10)
	return true

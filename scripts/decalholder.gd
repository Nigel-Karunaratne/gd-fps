class_name DecalHolder
extends Node3D

const MAX_DECALS: int = 25
var instantiated_decals: Array[Node3D]
var decal_resources: Resource = preload("res://prefabs/anchor.tscn")

func _ready() -> void:
	EventBus.s_deploydecal.connect(create_new_decal)

func create_new_decal(global_position: Vector3, _normal: Vector3) -> void:
	if len(instantiated_decals) >= MAX_DECALS:
		var old_dec = instantiated_decals.pop_front()
		old_dec.queue_free()
	var decal: Node3D = decal_resources.instantiate()
	add_child(decal)
	instantiated_decals.push_back(decal)
	#var rotation_to_apply = Quaternion(decal.transform.basis.y, _normal)
	#decal.global_basis = Basis(decal.transform.basis.get_rotation_quaternion() * rotation_to_apply)
	
	# If the direction between the decal and the decal+normal is parallel to the "up" direction (Vec.FORWARD), this fails so we need a workaround.
	if (_normal * Vector3.FORWARD).length() < 1:
		decal.look_at(decal.global_position + _normal, Vector3.FORWARD)
	else: # if they are parallel, either don't change rotation or rotate 180 degrees
		if _normal.z == 1:
			decal.rotation_degrees.y = 180
		
	decal.global_position = global_position

func clear_all_decals() -> void:
	for dec in instantiated_decals:
		dec.queue_free()

class_name EnemyHitBoxBase
extends CollisionObject3D

@export var critical : bool = false ## Should being hit in this CollisionObject3D cause critical damage? Defaults to "false"
var _enemy_ref : BaseEnemy ## Reference to owning enemy, set at runtime

func on_hit(damage: int) -> void:
	_enemy_ref.on_hit(damage,critical)

func get_enemy() -> BaseEnemy:
	return _enemy_ref

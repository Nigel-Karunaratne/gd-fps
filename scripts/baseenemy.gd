class_name BaseEnemy
extends Node3D

@export var max_health: int ## Maximum HP of enemy
var health: int             ## Current HP of enemy
@export var critical_hit_multiplier: float = 1.2 ## The multiplier for how much damage a damage instance does if it is critical

@export var hitboxes : Array[EnemyHitBoxBase] ## All hitboxes for this enemy

func _ready() -> void:
	health = max_health
	if hitboxes.is_empty():
		push_warning("An instantiated enemy does NOT have its hitboxes set. Auto-Setting hitboxes...")
		for c in get_children():
			if c is EnemyHitBoxBase:
				hitboxes.append(c)
	hitboxes.map(func(hitbox): hitbox._enemy_ref = self)

func on_hit(damage: int, is_critical: bool):
	health -= damage * (critical_hit_multiplier if is_critical else 1)
	print("HIT ENEMY FOR ", str(damage * (critical_hit_multiplier if is_critical else 1)), " DAMAGE")
	if health <= 0:
		die()

func die() -> void:
	queue_free()

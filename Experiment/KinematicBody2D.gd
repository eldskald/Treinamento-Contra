extends KinematicBody2D

export(int) var max_health
export(int) var max_speed
export(int) var gravity_acceleration
export(int) var damage

export(float) var shoot_cooldown

export(PackedScene) var bullet

onready var health: int = max_health

func is_dead() -> bool:
	return health <= 0

func take_damage(damage_amount: int, source_direction: Vector2) -> void:
	health -= damage_amount
	

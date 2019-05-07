extends BaseCreature
class_name BaseEnemy

export(int) var contac_damage

func check_contact() -> void:
	for body in $HurtBox.get_overlapping_bodies():
		if body.is_in_group("player"):
			var damage_direction = body.position - self.position
			body.take_damage(contac_damage, damage_direction)

func shoot(gun: PackedScene, direction: Vector2) -> void:
	pass
extends BaseEnemy

func attack(direction: Vector2) -> void:
	var projectile = self.gun.instance()
	projectile.shoot_direction = direction
	projectile.position = self.position
	get_parent().add_child(projectile)
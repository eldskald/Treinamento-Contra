extends BaseEnemy

func _ready():
	move = -1

func attack(direction: Vector2) -> void:
	var projectile = self.gun.instance()
	projectile.shoot_direction = direction
	projectile.position = self.position
	get_parent().add_child(projectile)



func _on_Down_area_entered(area):
	if area.is_in_group("ledge"):
		move *= -1

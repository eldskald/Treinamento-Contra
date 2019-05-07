extends BaseProjectile

func _physics_process(delta):
	move(shoot_direction)

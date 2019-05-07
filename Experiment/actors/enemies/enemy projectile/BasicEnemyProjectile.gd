extends BaseProjectile

func _ready():
	self.rotate(shoot_direction.angle())

func _physics_process(delta):
	move(self.shoot_direction)

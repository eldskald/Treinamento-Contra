extends BaseCreature
class_name BaseEnemy

export(int) var contact_damage
export(float) var vision_range
export(float) var gravity_acceleration
export(float) var horizontal_acceleration
export(float) var max_horizontal_speed

var is_attacking: bool

func _ready():
	parse()

func check_contact() -> void:
	for body in $HurtBox.get_overlapping_bodies():
		if body.is_in_group("player"):
			var damage_direction = body.position - self.position
			body.take_damage(contact_damage, damage_direction)

func attack(direction: Vector2) -> void:
	pass

func parse():
	self.gravity = gravity_acceleration
	self.acceleration = horizontal_acceleration
	self.max_natural_speed = max_horizontal_speed
	self.max_falling_speed = 300000
	self.max_rising_speed = 300000
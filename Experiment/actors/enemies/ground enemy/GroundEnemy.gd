extends BaseEnemy

func _ready():
	self.gravity = 1000

func attack(gun: PackedScene, direction: Vector2) -> void:
	print("shoot")
extends Area2D

export(float) var SPEED
export(float) var damage

var direction = Vector2()
var angle = direction.angle()

func _physics_process(delta):
	position += SPEED*direction*delta


func _on_Basic_Enemy_Projectile_body_entered(body):
	if body.is_in_group("player"):
		body._take_damage(1, direction.x)
		self.queue_free()

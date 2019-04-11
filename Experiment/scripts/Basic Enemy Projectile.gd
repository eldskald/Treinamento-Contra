extends Area2D

export(float) var SPEED
export(float) var damage

var angle = direction.angle()
var direction = Vector2()
func _physics_process(delta):
	position += SPEED*direction*delta


func _on_Basic_Enemy_Projectile_body_entered(body):
	if body.is_in_group("player"):
		body._take_damage(damage)
		self.queue_free()

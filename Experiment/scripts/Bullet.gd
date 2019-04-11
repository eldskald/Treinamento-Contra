extends Area2D

export(float) var SPEED = 1000
export(float) var DESPAWN_TIME = 1000
export(float) var DAMAGE

var direction = Vector2()
var timer = 0

signal kill

func _physics_process(delta):
	position += SPEED*direction*delta
	timer += delta
	if timer >= DESPAWN_TIME / 1000:
		self.queue_free()

func _on_Bullet_body_entered(body):
	if body.is_in_group("Enemy"):
		body._do_damage(DAMAGE)
		self.queue_free()
	elif body.is_in_group("block"):
		self.queue_free()

extends Area2D

var direction = Vector2()
export(float) var SPEED
var angle = direction.angle()

func _physics_process(delta):
	position += SPEED*direction*delta
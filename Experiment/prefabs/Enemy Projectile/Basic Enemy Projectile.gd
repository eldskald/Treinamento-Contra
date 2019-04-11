extends Area2D

var direction = Vector2()
export(float) var SPEED

var playerPosition = Vector2()

var Distance = Vector2()


signal kill

func _physics_process(delta):
	position += SPEED*direction*delta
extends KinematicBody2D
class_name BaseProjectile

export(float) var speed
export(float) var life_time
export(String) var hurt_group

export(int) var damage

var direction:Vector2

func _ready():
	$LifeTimer.start(life_time)

func _on_LifeTimer_timeout():
	destroy()

func destroy():
	queue_free()

func move(direction):
	move_and_slide(direction*speed)


func _on_HurtBox_body_entered(body):
	if body.is_in_group(hurt_group):
		body.take_damage(damage, direction)
		destroy()
		queue_free()

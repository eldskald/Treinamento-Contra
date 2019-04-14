extends Area2D

export(float) var SPEED
export(float) var damage

var direction = Vector2()

func _physics_process(delta):
	position += SPEED*direction*delta                 #Bullet Trajectory (In this case is linear)


func _on_Basic_Enemy_Projectile_body_entered(body):   #If the bullet hit on something...
	if body.is_in_group("player"):                    #Check if it is in "Player" Group
		body._take_damage(damage, direction.x)        #Do damage on Player
		self.queue_free()                             #Destroy the bullet on impact

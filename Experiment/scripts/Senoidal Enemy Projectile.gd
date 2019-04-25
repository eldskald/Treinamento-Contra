extends Area2D

export(float) var SPEED
export(float) var sinPeak
export(float) var sinPhase
export(float) var damage

var up = 1
var playerPosition = Vector2()
var projectileTimer
var playerDirection = Vector2()
var normalToPlayerDirection = Vector2()
var referentialPosition = Vector2()
var normalPosition = Vector2()
var bulletOrientation = Vector2()


func _ready():
	referentialPosition = position
	projectileTimer = 0
	playerDirection = playerPosition - position
	playerDirection = playerDirection.normalized()
	normalToPlayerDirection = playerDirection.rotated(PI/2)*up

func _process(delta):
	projectileTimer += delta*sinPhase
	referentialPosition += playerDirection*SPEED*delta
	normalPosition = normalToPlayerDirection*sin(projectileTimer)*sinPeak
	bulletOrientation = playerDirection*SPEED + normalToPlayerDirection*cos(projectileTimer)*sinPeak*sinPhase
	position = referentialPosition + normalPosition
	rotation = bulletOrientation.angle() - PI
	pass


func _on_Senoidal_Enemy_Projectile_body_entered(body):
	if body.is_in_group("player"):                    
		body._take_damage(damage, playerDirection.x)             
		self.queue_free()  


func _on_VisibilityEnabler2D_screen_exited():
	self.queue_free()

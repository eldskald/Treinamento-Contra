extends Area2D

export(float) var GRAVITY
export(float) var dissipation
export(int) var explosionRadius
export(float) var damage
export(float) var explosionTime
export(float) var maxHealth

var bombReleased
var velocity = Vector2()
var SPEED
var exploding = false
var health

# Called when the node enters the scene tree for the first time.
func _ready():
	health = maxHealth

func _process(delta):
	if bombReleased and !exploding:
		velocity.y += GRAVITY
		velocity.x = SPEED
		position += velocity*delta
		
		if health == 0:
			explode()


func _on_Wheel_bomb_body_entered(body):
	if body.is_in_group("floor"):
		velocity.y *= -1*dissipation
	if body.is_in_group("player"):
		body._take_damage(damage, velocity.x)
		explode()

func explode():
	if !exploding:
		self.scale *= explosionRadius
		$"Explosion Timer".start(explosionTime)
	exploding = true


func _on_Timer_timeout():
	explode()


func _on_Explosion_Timer_timeout():
	self.queue_free()

func _do_damage(DAMAGE):
	health -= DAMAGE


func _on_Wheel_bomb_area_entered(area):
	if area.is_in_group("player bullet"):
		_do_damage(area.DAMAGE)
		area.queue_free()

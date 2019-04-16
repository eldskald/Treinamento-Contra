extends KinematicBody2D

export(float) var SPEED
export(float) var GRAVITY
export(float) var PERIOD

var velocity = Vector2()
var freeFallTimer
var fallTime

# Called when the node enters the scene tree for the first time.
func _ready():
	fallTime = PERIOD
	freeFallTimer = fallTime
	print(freeFallTimer)

func _physics_process(delta):
	velocity.y += GRAVITY*delta
	
	if freeFallTimer <= 0:
		velocity.y *= -1
		freeFallTimer = fallTime
		print(position.y)
	
	else:
		freeFallTimer -= delta
	
	_Hvelocity()
	
	
	velocity = move_and_slide(velocity)

func _Hvelocity():
	velocity.x = SPEED


func _on_Area2D_body_entered(body):
	if !body.is_in_group("Player"):
		SPEED *= -1

func _do_damage(DAMAGE):
	self.queue_free()
	pass

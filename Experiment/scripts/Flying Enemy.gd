extends KinematicBody2D

export(float) var SPEED
export(float) var GRAVITY
export(float) var PERIOD
export(Vector2) var bombPosition
export(float) var bombTimer

var velocity = Vector2()
var freeFallTimer
var fallTime
var bombReleased

var wheelBomb = preload("res://prefabs/Enemy Projectile/Wheel bomb.tscn").instance()

# Called when the node enters the scene tree for the first time.
func _ready():
	fallTime = PERIOD
	freeFallTimer = fallTime
	wheelBomb.position = bombPosition
	self.add_child(wheelBomb)
	bombReleased = false
	

func _physics_process(delta):
	velocity.y += GRAVITY*delta
	
	if freeFallTimer <= 0:
		velocity.y *= -1
		freeFallTimer = fallTime
	
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


func _on_Player_Trigger_body_entered(body):
	if body.is_in_group("player") and !bombReleased:
		print("Entrou")
		release_bomb()
		pass

func release_bomb():
	self.remove_child(wheelBomb)
	wheelBomb.position.x = position.x + bombPosition.x
	wheelBomb.position.y = position.y + bombPosition.y
	wheelBomb.scale = scale
	wheelBomb.SPEED = SPEED
	wheelBomb.bombReleased = true
	wheelBomb.get_node("Timer").start(bombTimer)
	get_parent().add_child(wheelBomb)
	bombReleased = true
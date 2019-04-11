extends KinematicBody2D

export(float) var gravityAccel
export(float) var shootCoolDown

var internalTimer = 0
var velocity = Vector2()
var playerDirection = Vector2()
var bullet = preload("res://prefabs/Enemy Projectile/Basic Enemy Projectile.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity.y += gravityAccel*delta
	velocity = move_and_slide(velocity)
	if internalTimer >= shootCoolDown:
		shoot()
		internalTimer = 0
	else:
		internalTimer += delta
#	pass

func kill():
	self.queue_free()

func shoot():
	playerDirection = get_parent().get_node_or_null("Player").position - position
	playerDirection = playerDirection.normalized()
	var projectile = bullet.instance()
	projectile.direction = playerDirection
	projectile.position = position + playerDirection*10
	projectile.rotation += playerDirection.angle()
	get_parent().add_child(projectile)

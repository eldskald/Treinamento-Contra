extends KinematicBody2D

export(float) var gravityAccel
export(float) var shootCoolDown
export(float) var maxHealth

var health = 0
var internalTimer = 0
var velocity = Vector2()
var playerDirection = Vector2()
var bullet = preload("res://prefabs/Enemy Projectile/Basic Enemy Projectile.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	health = maxHealth

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity.y += gravityAccel*delta
	velocity = move_and_slide(velocity)
	
	### Shooting ###
	if internalTimer >= shootCoolDown:
		shoot()
		internalTimer = 0
	else:
		internalTimer += delta
	#################
	
	if health <= 0:
		kill()
	
#	pass

func _do_damage(damage):
	health -= damage

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

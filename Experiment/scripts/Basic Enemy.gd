extends KinematicBody2D

export(float) var gravityAccel
export(float) var shootCoolDown
export(float) var maxHealth
export(float) var bulletSpawnRadius

var health = 0
var internalTimer = 0
var velocity = Vector2()
var playerDirection = Vector2()
var bullet = preload("res://prefabs/Enemy Projectile/Basic Enemy Projectile.tscn")
var parabolicalBullet = preload("res://prefabs/Enemy Projectile/Senoidal Enemy Projectile.tscn")
export(bool) var isSenoidalProjectile = false
var isBasicProjectile

# Called when the node enters the scene tree for the first time.
func _ready():
	health = maxHealth
	isBasicProjectile = !isSenoidalProjectile

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity.y += gravityAccel*delta
	velocity = move_and_slide(velocity)
	
	### Shooting ###
	if internalTimer >= shootCoolDown:
		if isBasicProjectile:
			shoot()
		else:
			senoidalShoot()
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
	playerDirection = get_parent().get_node_or_null("Player").position - position #
	playerDirection = playerDirection.normalized()                                #Creating a vector from Player to Enemy
	
	var projectile = bullet.instance()                                            #Creating a instance of the Projectile
	
	projectile.direction = playerDirection                                        # Parsing the direction to the bullet
	projectile.position = position + playerDirection*bulletSpawnRadius            # The spawnpoint of the bullet will be "spawnRadius" píxels from Enemy origin, on the Player direction	
	projectile.rotation += playerDirection.angle()                                # Rotating the bullet Sprite and Collisionbox for consistency
	
	get_parent().add_child(projectile)     

func senoidalShoot():
	var playerPosition = get_parent().get_node_or_null("Player").position
	
	var projectile = parabolicalBullet.instance()
	
	projectile.playerPosition = playerPosition
	projectile.position = position + playerDirection*bulletSpawnRadius
	
	get_parent().add_child(projectile) 
	
	var projectile2 = parabolicalBullet.instance()
	
	projectile2.playerPosition = playerPosition
	projectile2.position = position + playerDirection*bulletSpawnRadius
	projectile2.up = -1
	
	get_parent().add_child(projectile2) 
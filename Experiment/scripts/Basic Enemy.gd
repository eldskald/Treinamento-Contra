extends KinematicBody2D

export(float) var gravityAccel
export(float) var shootCoolDown
export(float) var maxHealth
export(float) var bulletSpawnRadius
export(float) var SPEED
export(Vector2) var burstRange
export(float) var timeBetweenBurstShots
export(bool) var jumpLedges
export(float) var jumpForce

var health = 0
var internalTimer = 0
var velocity = Vector2()
var playerDirection = Vector2()
var bullet = preload("res://prefabs/Enemy Projectile/Basic Enemy Projectile.tscn")
var senoidalBullet = preload("res://prefabs/Enemy Projectile/Senoidal Enemy Projectile.tscn")
export(bool) var isSenoidalProjectile = false
var isBasicProjectile
var shotsPerBurst
var burstTime
var playerInRange

# Called when the node enters the scene tree for the first time.
func _ready():
	health = maxHealth
	isBasicProjectile = !isSenoidalProjectile
	internalTimer = 0
	velocity.x = -SPEED
	burstTime = timeBetweenBurstShots
	playerInRange = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity.y += gravityAccel*delta
	
	### Shooting ###
	if internalTimer <= 0 and playerInRange:
		
		shotsPerBurst = randi() % int(burstRange.y) + int(burstRange.x)
		
		if isBasicProjectile:
			print("entrou")
			shoot()
		else:
			senoidalShoot()
			
			
		internalTimer = shootCoolDown
	
	elif internalTimer > 0:
		internalTimer -= delta
	#################
	
	if health <= 0:
		kill()
	
	velocity = move_and_slide(velocity)
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
	
	var projectile = senoidalBullet.instance()
	
	projectile.playerPosition = playerPosition
	projectile.position = position + playerDirection*bulletSpawnRadius
	
	get_parent().add_child(projectile) 
	
	var projectile2 = senoidalBullet.instance()
	
	projectile2.playerPosition = playerPosition
	projectile2.position = position + playerDirection*bulletSpawnRadius
	projectile2.up = -1
	
	get_parent().add_child(projectile2) 


func _on_Area2D_area_entered(area):
	if area.is_in_group("ledge"):
		velocity.x *= -1



func _on_Player_Sentinel_body_entered(body):
	if body.is_in_group("player"):
		playerInRange = true


func _on_Player_Sentinel_body_exited(body):
	if body.is_in_group("player"):
		playerInRange = false

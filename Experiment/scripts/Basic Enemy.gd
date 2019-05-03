extends KinematicBody2D

export(float) var maxHealth

export(float) var gravityAccel
export(float) var SPEED
export(bool) var jumpLedges
export(float) var jumpForce

export(Vector2) var burstRange
export(float) var timeBetweenBurstShots

export(float) var shootCoolDown
export(float) var bulletSpawnRadius

var health = 0
var internalTimer = 0

var velocity = Vector2()
var walkDirection = 1

var playerDirection = Vector2()
var bullet = preload("res://prefabs/Enemy Projectile/Basic Enemy Projectile.tscn")
var senoidalBullet = preload("res://prefabs/Enemy Projectile/Senoidal Enemy Projectile.tscn")
export(bool) var isSenoidalProjectile = false
var isBasicProjectile
var shotsPerBurst
var burstTime
var isBursting = false
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
	if (internalTimer <= 0 and playerInRange) or isBursting:
		
		if !isBursting:
			shotsPerBurst = randi() % int(burstRange.y - burstRange.x + 1) + int(burstRange.x)
			isBursting = true
			burstTime = timeBetweenBurstShots
		
		if shotsPerBurst > 0 and burstTime >= timeBetweenBurstShots:
			
			print (shotsPerBurst)
			if isBasicProjectile:
				shoot()
			else:
				senoidalShoot()
			
			burstTime = 0
			shotsPerBurst -= 1
		
		elif burstTime < timeBetweenBurstShots:
			burstTime += delta
		
		else:
			isBursting = false
			internalTimer = shootCoolDown
	
	elif internalTimer > 0:
		internalTimer -= delta
	#################
	
	if health <= 0:
		kill()
	
	
	if playerInRange:
		velocity.x = 0
	
	else:
		velocity.x = SPEED*walkDirection
	
	velocity = move_and_slide(velocity)
#	pass

func take_damage(damage, direction = Vector2()):
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
		walkDirection *= -1



func _on_Player_Sentinel_body_entered(body):
	if body.is_in_group("player"):
		playerInRange = true


func _on_Player_Sentinel_body_exited(body):
	if body.is_in_group("player"):
		playerInRange = false

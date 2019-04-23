extends KinematicBody2D

export(float) var HEARTS = 3                       # Player's total number of hearts. Each heart represents 2 hit points.
export(float) var HEAL_PACKS = 3                   # Player's heal packs maximum.
export(float) var MAXIMUM_SPEED = 300              # Player's maximum horizontal move speed in pixels per second.
export(float) var ACCELERATION = 1400              # Player's horizontal acceleration in pixels per second per second.
export(float) var GRAVITY = 1800                   # Gravity's acceleration in pixels per second per second.
export(float) var JUMP_SPEED = 600                 # Vertical initial speed of a jump in pixels per second.
export(float) var WALL_JUMP_SPEED = 400            # Vertical initial speed of a wall jump in pixels per second.
export(float) var MAX_FALLING_SPEED = 600          # Maximum falling speed in pixels per second.
export(float) var GLIDING_FALL_SPEED = 100         # Falling speed when gliding.
export(float) var FAST_FALL_MULTIPLIER = 3         # Speed and gravity multiplier when fast falling.
export(float) var WALL_FALL = 50                   # Falling speed in pixels per second when sliding down a wall.
export(float) var EARLY_JUMP = 80                  # Pity timer for an early jump on miliseconds
export(float) var COYOTE_JUMP = 80                 # Pity timer of a coyote jump on miliseconds.
export(float) var DODGE_DISTANCE = 128             # Distance in pixels covered by a dodge.
export(float) var DODGE_DURATION = 150             # Duration in miliseconds of a dodge.
export(float) var DODGE_INVINCIBILITY = 120        # Time in miliseconds of invincibility after starting a dodge.
export(float) var HEALING_TIME = 1000              # Time in miliseconds the player must hold the heal button to heal.
export(float) var RATE_OF_FIRE = 400               # Cooldown in miliseconds before being able to fire again.
export(float) var DAMAGE_INVINCIBILITY = 1000      # Invincibility time after taking damage.

var velocity = Vector2()                # Player's velocity vector.
var hitPoints = 2 * HEARTS              # Player's current hit points. The maximum is twice the HEARTS value.
var healPacks = HEAL_PACKS              # Player's current heal packs total.

var jumpInput = false         # True when player is pressing the jump button before it reaches the jump's maximum height.
var wallJumpInput = false     # For wall jump, works almost in the same way as jumpInput.
var fastFalling = false       # True when the player is fast falling.
var earlyTime = -1            # Early jump pity timer countdown.
var coyoteTime = -1           # Coyote jump pity timer countdown.
var leftLedge = false         # True if the character is hanging from a platform ledge on his left.
var rightLedge = false        # True if the character is hanging from a platform ledge on his right.
var leftLedgeAnim = false     # True if the character is jumping from a ledge onto a platform on the left.
var rightLedgeAnim = false    # True if the character is jumping from a ledge onto a platform on the right.
var dodgeAnim = false         # True when the player is on a dodge animation.
var damageAnim = false        # True when the player is on a take damage animation.
var invincible = false        # True when the player is invincible after taking damage.
var animTimer = -1            # Timer count for animations.
var playerFacing = 1          # Equals 1 when facing right and -1 when facing left.
var dodgeAvailable = true     # True when the player can dodge.
var isHealing = false         # True when the player is healing.

signal displayHitPoints (hearts, currentHp)      # Signal sent to the UI to update the hearts display.

var upPressed = false     # True when the player pressed any up button or tilted the left stick up.
var leftPressed = false   # True when the player pressed any left button or tilted the left stick left.
var downPressed = false   # True when the player pressed any down button or tilted the left stick down.
var rightPressed = false  # True when the player pressed any right button or tilted the left stick right.
var upHold = false        # True when the player is holding any up button or tilting the left stick up.
var leftHold = false      # True when the player is holding any left button or tilting the left stick left.
var downHold = false      # True when the player is holding any down button or tilting the left stick down.
var rightHold = false     # True when the player is holding any right button or tilting the left stick right.
var upReleased = false    # True when the player released any up button or returned the left stick from the up position.
var leftReleased = false  # True when the player released any left button or returned the left stick from the left position.
var downReleased = false  # True when the player released any down button or returned the left stick from the down position.
var rightReleased = false # True when the player released any right button or returned the left stick from the right position.
var stickInput = 10       # Used to aid the function that gets directional inputs.

var touchFloor = 0            # Counts how many bodies the floor detector finds.
var leftWall = 0              # Counts how many bodies the left wall detector finds.
var leftWall2 = 0             # Counts how many bodies the left wall detector 2 finds.
var rightWall = 0             # Counts how many bodies the right wall detector finds.
var rightWall2 = 0            # Counts how many bodies the right wall detector 2 finds.

var bullet = preload("res://prefabs/Bullet.tscn")        # Projectile prefab shot by the player.
var shootingDirection = Vector2(1, 0)                    # The direction the player is shooting.
var shootingCooldown = 0                                 # Timer to shoot again.

func _ready():
	emit_signal("displayHitPoints", HEARTS, hitPoints, HEAL_PACKS, healPacks)

func _physics_process(delta):
	
	_directional_inputs()
	
	_heal(delta)
	if damageAnim or invincible:
		_take_damage_animation(delta)
		if animTimer >= 0.4 and (leftPressed or rightPressed or upPressed or downPressed or Input.is_action_just_pressed("ui_jump") or Input.is_action_just_pressed("ui_dodge")):
			damageAnim = false
	if !damageAnim and !isHealing:
		if !dodgeAnim:
			if leftLedgeAnim or rightLedgeAnim:
				if (rightHold  or leftHold) and animTimer > 0.2:
					leftLedgeAnim = false
					rightLedgeAnim = false
					animTimer = -1
			else:
				if !(leftLedge or rightLedge or leftLedgeAnim or rightLedgeAnim):
					_moving(delta)
			_jumping(delta)
			_shooting(delta)
		_dodging(delta)
	
	velocity = move_and_slide(velocity, Vector2(0,-1))

# This function handles the directional inputs and double clicks. We need them because either the buttons or the
# left analog stick should yield this, which means there should be lots of things to read instead of just the action.

func _directional_inputs():
	var buttonUpPressed = Input.is_action_just_pressed("ui_up")
	var buttonLeftPressed = Input.is_action_just_pressed("ui_left")
	var buttonDownPressed = Input.is_action_just_pressed("ui_down")
	var buttonRightPressed = Input.is_action_just_pressed("ui_right")
	var buttonUpHold = Input.is_action_pressed("ui_up")
	var buttonLeftHold = Input.is_action_pressed("ui_left")
	var buttonDownHold = Input.is_action_pressed("ui_down")
	var buttonRightHold = Input.is_action_pressed("ui_right")
	var buttonUpReleased = Input.is_action_just_released("ui_up")
	var buttonLeftReleased = Input.is_action_just_released("ui_left")
	var buttonDownReleased = Input.is_action_just_released("ui_down")
	var buttonRightReleased = Input.is_action_just_released("ui_right")
	
	# This code handles the left stick inputs.
	
	var stick = Vector2(Input.get_joy_axis(0, JOY_ANALOG_LX), Input.get_joy_axis(0, JOY_ANALOG_LY))
	var angle
	if stick.length() > 0.2:
		angle = stick.angle()
	else:
		angle = 10
	
	if !(stickInput <= -PI/8 and stickInput >= -7*PI/8) and (angle <= -PI/8 and angle >= -7*PI/8):
		upPressed = true
		upHold = true
	else:
		upPressed = false
	if !(stickInput <= -5*PI/8 or stickInput >= 5*PI/8 and stickInput != 10) and (angle <= -5*PI/8 or angle >= 5*PI/8 and angle != 10):
		leftPressed = true
		leftHold = true
	else:
		leftPressed = false
	if !(stickInput >= PI/8 and stickInput <= 7*PI/8) and (angle >= PI/8 and angle <= 7*PI/8):
		downPressed = true
		downHold = true
	else:
		downPressed = false
	if !(stickInput >= -3*PI/8 and stickInput <= 3*PI/8) and (angle >= -3*PI/8 and angle <= 3*PI/8):
		rightPressed = true
		rightHold = true
	else:
		rightPressed = false
	
	upHold = (stickInput <= -PI/8 and stickInput >= -7*PI/8) and (angle <= -PI/8 and angle >= -7*PI/8)
	leftHold = (stickInput <= -5*PI/8 or stickInput >= 5*PI/8 and stickInput != 10) and (angle <= -5*PI/8 or angle >= 5*PI/8 and angle != 10)
	downHold = (stickInput >= PI/8 and stickInput <= 7*PI/8) and (angle >= PI/8 and angle <= 7*PI/8)
	rightHold = (stickInput >= -3*PI/8 and stickInput <= 3*PI/8) and (angle >= -3*PI/8 and angle <= 3*PI/8)
	
	upReleased = (stickInput <= -PI/8 and stickInput >= -7*PI/8) and !(angle <= -PI/8 and angle >= -7*PI/8)
	leftReleased = (stickInput <= -5*PI/8 or stickInput >= 5*PI/8 and stickInput != 10) and !(angle <= -5*PI/8 or angle >= 5*PI/8 and angle != 10)
	downReleased = (stickInput >= PI/8 and stickInput <= 7*PI/8) and !(angle >= PI/8 and angle <= 7*PI/8)
	rightReleased = (stickInput >= -3*PI/8 and stickInput <= 3*PI/8) and !(angle >= -3*PI/8 and angle <= 3*PI/8)
	
	stickInput = angle
	
	# This last part handles the final inputs.
	
	upPressed = upPressed or buttonUpPressed
	leftPressed = leftPressed or buttonLeftPressed
	downPressed = downPressed or buttonDownPressed
	rightPressed = rightPressed or buttonRightPressed
	
	upHold = upHold or buttonUpHold
	leftHold = leftHold or buttonLeftHold
	downHold = downHold or buttonDownHold
	rightHold = rightHold or buttonRightHold
	
	upReleased = upReleased or buttonUpReleased
	leftReleased = leftReleased or buttonLeftReleased
	downReleased = downReleased or buttonDownReleased
	rightReleased = rightReleased or buttonRightReleased

# This function handles horizontal movement. It is written to accelerate the player character until it reaches
# MAXIMUM_SPEED as long as the player is pressing the directional input. If the player releases it, the character
# instantly breaks to zero horizontal velocity. This is to allow fine control of the character, where it stops
# moving when you are not pressing a button and the acceleration is to allow moving short distances with a quick
# press of the button easier.

func _moving(delta):
	if rightHold and !leftHold:
		if !(rightWall2 > 0 and wallJumpInput):
			if velocity.x >= 0 and velocity.x < MAXIMUM_SPEED:
				if velocity.x + ACCELERATION * delta < MAXIMUM_SPEED:
					velocity.x += ACCELERATION * delta
				else:
					velocity.x = MAXIMUM_SPEED
			elif velocity.x < 0:
				velocity.x = 0
			if !((leftWall > 0 or rightWall > 0) and touchFloor == 0):
				playerFacing = 1
	elif !rightHold and leftHold:
		if !(leftWall2 > 0 and wallJumpInput):
			if velocity.x <= 0 and velocity.x > -MAXIMUM_SPEED:
				if velocity.x - ACCELERATION * delta > -MAXIMUM_SPEED:
					velocity.x -= ACCELERATION * delta
				else:
					velocity.x = -MAXIMUM_SPEED
			elif velocity.x > 0:
				velocity.x = 0
			if !((leftWall > 0 or rightWall > 0) and touchFloor == 0):
				playerFacing = -1
	elif !wallJumpInput:
		velocity.x = 0

# This function handles jumping. The normal jump is designed to keep the character's vertical speed as long as the
# player keeps pressing the jump button, and it instantly removes all upward vertical velocity the character has
# when the player let go of the button. This is to allow finer control to dodge projectiles and obstacles.

func _jumping(delta):
	if touchFloor > 0 and Input.is_action_just_pressed("ui_jump"):
		velocity.y = -JUMP_SPEED
		jumpInput = true
	elif jumpInput and Input.is_action_just_released("ui_jump"):
		velocity.y = 0
		jumpInput = false
	elif jumpInput and velocity.y >= 0:
		jumpInput = false
	
	# This part handles the early jumps. When the player wants to make consecutive jumps, it is easy to press the jump
	# too soon, before the character actually hits the ground, which results in no jump at all. This code prevents it from
	# happening, allowing the game to recognize jump inputs in a certain window of time given by EARLY_JUMP.
	
	if touchFloor == 0 and Input.is_action_just_pressed("ui_jump"):
		earlyTime = 0
	if touchFloor == 0 and earlyTime >= 0 and Input.is_action_pressed("ui_jump"):
		earlyTime += delta
		if earlyTime > EARLY_JUMP / 1000:
			earlyTime = -1
	elif touchFloor > 0 and earlyTime >= 0 and Input.is_action_pressed("ui_jump") and !fastFalling:
		earlyTime = -1
		jumpInput = true
		velocity.y = -JUMP_SPEED
	elif touchFloor > 0 and earlyTime >= 0:
		earlyTime = -1
	
	# A coyote jump is designed to allow easier jumps out of corners. If the player jumps after leaving the platform,
	# they will not jump. This gives them a window of COYOTE_JUMP miliseconds to jump right after leaving a platform,
	# making those jumps much easier, providing a better game feel and character control.
	
	if touchFloor == 0 and coyoteTime >= 0:
		coyoteTime += delta
		if coyoteTime > COYOTE_JUMP / 1000:
			coyoteTime = -1
		if Input.is_action_just_pressed("ui_jump"):
			velocity.y = -JUMP_SPEED
			jumpInput = true
			coyoteTime = -1
	elif touchFloor > 0 and coyoteTime >= 0:
		coyoteTime = -1
	
	# The wall jumps are designed to work both off of the jump button and the directional button yielding the same results.
	# A combination of GRAVITY, WALL_JUMP_SPEED, ACCELERATION and the size of the wall detectors 2 hitboxes can allow or
	# disallow wall climbing by jumping and going back to the wall. Only nodes with the 'wall' group allow for wall jumps.
	
	if touchFloor == 0 and leftWall > 0 and (Input.is_action_just_pressed("ui_jump") or rightPressed):
		velocity.y = -WALL_JUMP_SPEED
		velocity.x = MAXIMUM_SPEED
		wallJumpInput = true
	elif wallJumpInput and (Input.is_action_just_released("ui_jump") or rightReleased):
		if velocity.y < 0:
			velocity.y = 0
		wallJumpInput = false
	elif wallJumpInput and touchFloor > 0:
		wallJumpInput = false
	
	if touchFloor == 0 and rightWall > 0 and (Input.is_action_just_pressed("ui_jump") or leftPressed):
		velocity.y = -WALL_JUMP_SPEED
		velocity.x = -MAXIMUM_SPEED
		wallJumpInput = true
	elif wallJumpInput and (Input.is_action_just_released("ui_jump") or leftReleased):
		if velocity.y < 0:
			velocity.y = 0
		wallJumpInput = false
	elif wallJumpInput and touchFloor > 0:
		wallJumpInput = false
	
	# This code handles jumping from a ledge into a platform.
	
	if leftLedge and (upPressed or leftPressed):
		leftLedgeAnim = true
		animTimer = 0
		self.position.x += 5
		velocity = Vector2(0, -400)
	elif leftLedgeAnim:
		animTimer += delta
		if animTimer >= 0.1 and velocity.x > - MAXIMUM_SPEED:
			velocity.x -= ACCELERATION * delta
		if animTimer >= 0.3:
			leftLedgeAnim = false
			animTimer = -1
	
	if rightLedge and (upPressed or rightPressed):
		rightLedgeAnim = true
		animTimer = 0
		self.position.x -= 5
		velocity = Vector2(0, -400)
	elif rightLedgeAnim:
		animTimer += delta
		if animTimer >= 0.1 and velocity.x < MAXIMUM_SPEED:
			velocity.x += ACCELERATION * delta
		if animTimer >= 0.3:
			rightLedgeAnim = false
			animTimer = -1
	
	# This code handles letting go of ledges and walls.
	
	if leftWall > 0 and downHold:
		position.x += 5
	if rightWall > 0 and downHold:
		position.x -= 5
	
	# This part of the code handles gravity and sliding down walls.
	
	if (leftWall > 0 or rightWall > 0) and velocity.y >= 0 and !(leftLedge or rightLedge or leftLedgeAnim or rightLedgeAnim):
		velocity.y = WALL_FALL
		if leftWall > 0 and playerFacing != 1:
			playerFacing = 1
		elif rightWall > 0 and playerFacing != -1:
			playerFacing = -1
	elif (leftLedge or rightLedge) and !wallJumpInput and !(leftLedgeAnim or rightLedgeAnim):
		velocity.y = 0
		if leftWall > 0 and playerFacing != 1:
			playerFacing = 1
		elif rightWall > 0 and playerFacing != -1:
			playerFacing = -1
	elif Input.is_action_pressed("ui_jump") and earlyTime == -1 and !fastFalling and leftWall == 0 and rightWall == 0 and !(leftLedge or rightLedge or leftLedgeAnim or rightLedgeAnim):
		if velocity.y < GLIDING_FALL_SPEED and velocity.y + GRAVITY*delta < GLIDING_FALL_SPEED:
			velocity.y += GRAVITY*delta
		elif velocity.y >= GLIDING_FALL_SPEED:
			velocity.y = GLIDING_FALL_SPEED
	else:
		if downHold and !upHold and leftWall == 0 and rightWall == 0 and Input.is_action_just_pressed("ui_jump") and touchFloor == 0:
			fastFalling = true
			velocity.y = MAX_FALLING_SPEED*FAST_FALL_MULTIPLIER
		if fastFalling and touchFloor > 0:
			fastFalling = false
		if velocity.y < MAX_FALLING_SPEED and velocity.y + GRAVITY*delta < MAX_FALLING_SPEED:
			velocity.y += GRAVITY*delta
		elif velocity.y < MAX_FALLING_SPEED and velocity.y + GRAVITY*delta >= MAX_FALLING_SPEED:
			velocity.y = MAX_FALLING_SPEED

# This function handles dodging. Dodges are not only a way of traversal as a way to defend against projectiles and
# enemies. It is designed to work as a quick dash in the direction the player is pressing on the move inputs, covering
# a vertical distance and/or horizontal distance equal to DODGE_DISTANCE pixels in DODGE_DURATION miliseconds. The player
# is invincible for DODGE_INVINCIBILITY miliseconds after a pushing the dodge button, going through all projectiles
# and enemy hitboxes. After dodging in the air, the player must hit the ground, jump off of a projectile or cling to
# a wall to be able to dodge again.

func _dodging(delta):
	if touchFloor > 0 or leftWall > 0 or rightWall > 0:
		dodgeAvailable = true
	if Input.is_action_just_pressed("ui_dodge") and !dodgeAnim and dodgeAvailable:
		dodgeAnim = true
		dodgeAvailable = false
		jumpInput = false
		wallJumpInput = false
		earlyTime = -1
		leftLedgeAnim = false
		rightLedgeAnim = false
		animTimer = 0
		var direction = Vector2(playerFacing, 0)
		if leftWall > 0 and touchFloor == 0:
			direction = Vector2(1,0)
		elif rightWall > 0 and touchFloor == 0:
			direction = Vector2(-1,0)
		else:
			if upHold:
				direction = Vector2(0,-1)
			if downHold:
				direction = Vector2(0,1)
			if leftHold and !(leftWall > 0 and touchFloor == 0):
				direction.x = -1
			if rightHold and !(rightWall > 0 and touchFloor == 0):
				direction.x = 1
		velocity = direction * DODGE_DISTANCE/(DODGE_DURATION/1000)
		set_collision_layer(2)
		set_collision_mask(2)
	elif dodgeAnim:
		animTimer += delta
		if animTimer >= DODGE_INVINCIBILITY/1000:
			set_collision_layer(1)
			set_collision_mask(1)
		if animTimer >= DODGE_DURATION/1000 or get_slide_count() > 0:
			set_collision_layer(1)
			set_collision_mask(1)
			velocity = Vector2(0,0)
			dodgeAnim = false
			animTimer = -1

# These next two functions handle the shooting. This first one detects the direction of the input

func _shooting(delta):
	if shootingCooldown > 0:
		shootingCooldown -= delta
	
	var stick = Vector2(Input.get_joy_axis(0, JOY_ANALOG_RX), Input.get_joy_axis(0, JOY_ANALOG_RY))
	if stick.length() > 0.2:
		shootingDirection = stick
		_shoot()
	
	if Input.is_action_pressed("ui_mouse_right_click"):
		shootingDirection = get_viewport().get_mouse_position()
		shootingDirection = Vector2(shootingDirection.x - self.get_global_transform_with_canvas().origin.x, shootingDirection.y - self.get_global_transform_with_canvas().origin.y)
		_shoot()
	
	if Input.is_action_pressed("ui_shoot_up") and !Input.is_action_pressed("ui_shoot_left") and !Input.is_action_pressed("ui_shoot_right"):
		shootingDirection = Vector2(0,-1)
		_shoot()
	elif Input.is_action_pressed("ui_page_up") or (Input.is_action_pressed("ui_shoot_up") and Input.is_action_pressed("ui_shoot_right")):
		shootingDirection = Vector2(1,-1)
		_shoot()
	elif Input.is_action_pressed("ui_shoot_right") and !Input.is_action_pressed("ui_shoot_up") and !Input.is_action_pressed("ui_shoot_down"):
		shootingDirection = Vector2(1,0)
		_shoot()
	elif Input.is_action_pressed("ui_page_down") or (Input.is_action_pressed("ui_shoot_right") and Input.is_action_pressed("ui_shoot_down")):
		shootingDirection = Vector2(1,1)
		_shoot()
	elif Input.is_action_pressed("ui_shoot_down") and !Input.is_action_pressed("ui_shoot_right") and !Input.is_action_pressed("ui_shoot_left"):
		shootingDirection = Vector2(0,1)
		_shoot()
	elif Input.is_action_pressed("ui_end") or (Input.is_action_pressed("ui_shoot_down") and Input.is_action_pressed("ui_shoot_left")):
		shootingDirection = Vector2(-1,1)
		_shoot()
	elif Input.is_action_pressed("ui_shoot_left") and !Input.is_action_pressed("ui_shoot_down") and !Input.is_action_pressed("ui_shoot_up"):
		shootingDirection = Vector2(-1,0)
		_shoot()
	elif Input.is_action_pressed("ui_home") or (Input.is_action_pressed("ui_shoot_left") and Input.is_action_pressed("ui_shoot_up")):
		shootingDirection = Vector2(-1,-1)
		_shoot()

func _shoot():
	if shootingCooldown <= 0:
		shootingCooldown = RATE_OF_FIRE / 1000
		var parent = get_parent()
		var projectile = bullet.instance()
		parent.add_child(projectile)
		projectile.position = position
		projectile.direction = shootingDirection.normalized()

# This function handles healing. It is designed to work when the player is standing still on the floor, holding the
# heal button for HEALING_TIME miliseconds. During this time, they can't move or shoot. If they take damage, they get
# interrupted and the process stops. They only spend the healing pack and get their hit points back after finishing
# this process uninterrupted.

func _heal(delta):
	if Input.is_action_just_pressed("ui_heal") and !damageAnim and !dodgeAnim and !leftLedgeAnim and !rightLedgeAnim and touchFloor > 0:
		if hitPoints < 2*HEARTS and healPacks > 0:
			isHealing = true
			animTimer = 0
	if Input.is_action_pressed("ui_heal") and isHealing and touchFloor > 0:
		animTimer += delta
		if animTimer >= HEALING_TIME / 1000:
			hitPoints = 2 * HEARTS
			healPacks -= 1
			emit_signal("displayHitPoints", HEARTS, hitPoints, HEAL_PACKS, healPacks)
			isHealing = false
			animTimer = -1
	elif (Input.is_action_just_released("ui_heal") or touchFloor == 0) and isHealing:
		isHealing = false
		animTimer = -1

func _take_damage(damage, impact):
	hitPoints -= damage
	emit_signal("displayHitPoints", HEARTS, hitPoints, HEAL_PACKS, healPacks)
	isHealing = false
	dodgeAnim = false
	leftLedgeAnim = false
	rightLedgeAnim = false
	damageAnim = true
	invincible = true
	animTimer = 0
	set_collision_layer(2)
	set_collision_mask(2)
	if impact > 0:
		velocity = Vector2(300,-300)
	else:
		velocity = Vector2(-300,-300)

func _take_damage_animation(delta):
	animTimer += delta
	if animTimer >= 0.1 and (touchFloor > 0 or leftWall > 0 or rightWall > 0) and damageAnim:
		damageAnim = false
	if animTimer >= DAMAGE_INVINCIBILITY / 1000:
		animTimer = -1
		invincible = false
		damageAnim = false
		set_collision_layer(1)
		set_collision_mask(1)
	if damageAnim:
		velocity.y += GRAVITY*delta

# These wall detectors allow for detection of walls and which side of the player they're touching. It also only detects
# nodes on the 'wall' group. This is better than is_on_wall() because it tells the direction the wall is on and it only
# detects walls on the 'wall' group, allowing us to control which walls are wall jumpable off of.

func _on_left_body_entered(body):
	if body.is_in_group("wall"):
		leftWall += 1

func _on_right_body_entered(body):
	if body.is_in_group("wall"):
		rightWall += 1

func _on_left_body_exited(body):
	if body.is_in_group("wall"):
		leftWall -= 1

func _on_right_body_exited(body):
	if body.is_in_group("wall"):
		rightWall -= 1

func _on_left_area_entered(area):
	if area.is_in_group("ledge") and leftWall > 0 and !dodgeAnim:
		if self.position.y - area.position.y >= 6:
			self.position.y = area.position.y + 16
			velocity = Vector2(0,0)
			leftLedge = true
			animTimer = -1
		else:
			leftLedgeAnim = true
			animTimer = 0
			position.x += 5
			velocity = Vector2(0, -400)

func _on_left_area_exited(area):
	if area.is_in_group("ledge"):
		leftLedge = false

func _on_right_area_entered(area):
	if area.is_in_group("ledge") and rightWall > 0 and !dodgeAnim:
		if self.position.y - area.position.y >= 6:
			self.position.y = area.position.y + 16
			velocity = Vector2(0,0)
			rightLedge = true
			animTimer = -1
		else:
			rightLedgeAnim = true
			animTimer = 0
			position.x -= 5
			velocity = Vector2(0, -400)

func _on_right_area_exited(area):
	if area.is_in_group("ledge"):
		rightLedge = false

# These second and larger wall detectors are for wall jumps. The player has to move these hitboxes out of the wall
# to be capable of going back to the wall while still going up. Without these, they can jump while keeping their
# distance from the wall as small as possible, even zero, allowing for easy climbing and bad movement overall, even
# wall jumping without leaving the wall.

func _on_left2_body_entered(body):
	if body.is_in_group("wall"):
		leftWall2 += 1

func _on_left2_body_exited(body):
	if body.is_in_group("wall"):
		leftWall2 -= 1

func _on_right2_body_entered(body):
	if body.is_in_group("wall"):
		rightWall2 += 1

func _on_right2_body_exited(body):
	if body.is_in_group("wall"):
		rightWall2 -= 1

# This detector is for detecting ground. It is better than is_on_floor() because they only detect nodes on the 'floor'
# group, allowing us to control which bodies are jumpable off of, to disallow the player from jumping from spikes,
# projectiles, enemies and other things we deem important.

func _on_down_body_entered(body):
	if body.is_in_group("floor"):
		touchFloor += 1

func _on_down_body_exited(body):
	if body.is_in_group("floor"):
		touchFloor -= 1
		if !jumpInput:    # For coyote jump
			coyoteTime = 0

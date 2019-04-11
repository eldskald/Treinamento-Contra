extends KinematicBody2D

export(float) var MAXIMUM_SPEED = 300              # Player's maximum horizontal move speed in pixels per second.
export(float) var ACCELERATION = 1400              # Player's horizontal acceleration in pixels per second per second.
export(float) var GRAVITY = 1800                   # Gravity's acceleration in pixels per second per second.
export(float) var JUMP_SPEED = 600                 # Vertical initial speed of a jump in pixels per second.
export(float) var WALL_JUMP_SPEED = 400            # Vertical initial speed of a wall jump in pixels per second.
export(float) var MAX_FALLING_SPEED = 600          # Maximum falling speed in pixels per second.
export(float) var GLIDING_FALL_SPEED = 100         # Falling speed when gliding.
export(float) var FAST_FALL_MULTIPLIER = 3         # Speed and gravity multiplier when fast falling.
export(float) var WALL_FALL = 50                   # Falling speed in pixels per second when sliding down a wall.
export(float) var COYOTE_JUMP = 80                 # Pity timer of a coyote jump on miliseconds.
export(float) var RATE_OF_FIRE = 200               # Cooldown in miliseconds before being able to fire again.

var velocity = Vector2()   # Player's velocity vector

var jumpInput = false         # True when player is pressing the jump button before it reaches the jump's maximum height.
var earlyJumpInput = false    # True when player is pressing the jump button on an early jump window.
var wallJumpInput = false     # For wall jump, works almost in the same way as jumpInput.
var coyoteTime = -1           # Coyote jump pity timer countdown.
var leftLedge = false         # True if the character is hanging from a platform ledge on his left.
var rightLedge = false        # True if the character is hanging from a platform ledge on his right.
var leftLedgeAnim = false     # True if the character is jumping from a ledge onto a platform on the left.
var rightLedgeAnim = false    # True if the character is jumping from a ledge onto a platform on the right.
var animTimer = -1            # Timer count for animations.

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
var touchFloor2 = 0           # Counts how many bodies the floor detector 2 finds.
var leftWall = 0              # Counts how many bodies the left wall detector finds.
var leftWall2 = 0             # Counts how many bodies the left wall detector 2 finds.
var rightWall = 0             # Counts how many bodies the right wall detector finds.
var rightWall2 = 0            # Counts how many bodies the right wall detector 2 finds.

var bullet = preload("res://prefabs/Bullet.tscn")        # Projectile prefab shot by the player
var shootingDirection = Vector2(1, 0)                    # The direction the player is shooting
var shootingCooldown = 0                                 # Timer to shoot again

func _physics_process(delta):
	
	_directional_inputs()
	
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
	
	velocity = move_and_slide(velocity, Vector2(0,-1))

# This function handles the directional inputs. We need them because either the buttons or the left analog stick
# should yield this, which means there should be lots of things to read instead of just the action.

func _directional_inputs():
	var buttonUpPressed = Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_page_up") or Input.is_action_just_pressed("ui_home")
	var buttonLeftPressed = Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_home") or Input.is_action_just_pressed("ui_end")
	var buttonDownPressed = Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("ui_end") or Input.is_action_just_pressed("ui_page_down")
	var buttonRightPressed = Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("ui_page_down") or Input.is_action_just_pressed("ui_page_up")
	var buttonUpHold = Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_page_up") or Input.is_action_pressed("ui_home")
	var buttonLeftHold = Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_home") or Input.is_action_pressed("ui_end")
	var buttonDownHold = Input.is_action_pressed("ui_down") or Input.is_action_pressed("ui_end") or Input.is_action_pressed("ui_page_down")
	var buttonRightHold = Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_page_down") or Input.is_action_pressed("ui_page_up")
	var buttonUpReleased = Input.is_action_just_released("ui_up") or Input.is_action_just_released("ui_page_up") or Input.is_action_just_released("ui_home")
	var buttonLeftReleased = Input.is_action_just_released("ui_left") or Input.is_action_just_released("ui_home") or Input.is_action_just_released("ui_end")
	var buttonDownReleased = Input.is_action_just_released("ui_down") or Input.is_action_just_released("ui_end") or Input.is_action_just_released("ui_page_down")
	var buttonRightReleased = Input.is_action_just_released("ui_right") or Input.is_action_just_released("ui_page_down") or Input.is_action_just_released("ui_page_up")
	
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
	elif !rightHold and leftHold:
		if !(leftWall2 > 0 and wallJumpInput):
			if velocity.x <= 0 and velocity.x > -MAXIMUM_SPEED:
				if velocity.x - ACCELERATION * delta > -MAXIMUM_SPEED:
					velocity.x -= ACCELERATION * delta
				else:
					velocity.x = -MAXIMUM_SPEED
			elif velocity.x > 0:
				velocity.x = 0
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
	# happening, allowing the game to recognize jump inputs in a certain window given by the second wall detector hitboxes.
	# See the second wall detector description on this script.
	
	if (touchFloor2 > 0 or (downHold and velocity.y >= MAX_FALLING_SPEED)) and touchFloor == 0 and Input.is_action_just_pressed("ui_jump"):
		earlyJumpInput = true
	if touchFloor > 0 and earlyJumpInput and Input.is_action_pressed("ui_jump"):
		earlyJumpInput = false
		jumpInput = true
		velocity.y = -JUMP_SPEED
	elif touchFloor > 0 and earlyJumpInput:
		earlyJumpInput = false
	
	# Coyote jump is designed to allow easier jumps out of corners. If the player jumps after leaving the platform,
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
	
	# This code handles letting go of ledges.
	
	if leftLedge and downPressed:
		position.x += 5
	if rightLedge and downPressed:
		position.x -= 5
	
	# This part of the code handles gravity and sliding down walls.
	
	if (leftWall > 0 or rightWall > 0) and velocity.y >= 0 and !(leftLedge or rightLedge or leftLedgeAnim or rightLedgeAnim):
		velocity.y = WALL_FALL
	elif (leftLedge or rightLedge) and !wallJumpInput and !(leftLedgeAnim or rightLedgeAnim):
		velocity.y = 0
	elif (upHold or Input.is_action_pressed("ui_jump")) and !earlyJumpInput and !downHold and leftWall == 0 and rightWall == 0 and !(leftLedge or rightLedge or leftLedgeAnim or rightLedgeAnim):
		if velocity.y < GLIDING_FALL_SPEED and velocity.y + GRAVITY*delta < GLIDING_FALL_SPEED:
			velocity.y += GRAVITY*delta
		elif velocity.y >= GLIDING_FALL_SPEED:
			velocity.y = GLIDING_FALL_SPEED
	else:
		var fallSpeed
		if downHold and !upHold and velocity.y >= 0:
			fallSpeed = FAST_FALL_MULTIPLIER
		else:
			fallSpeed = 1
		if velocity.y < MAX_FALLING_SPEED*fallSpeed and velocity.y + GRAVITY*fallSpeed*delta < MAX_FALLING_SPEED*fallSpeed:
			velocity.y += GRAVITY*fallSpeed*delta
		elif velocity.y < MAX_FALLING_SPEED*fallSpeed and velocity.y + GRAVITY*fallSpeed*delta >= MAX_FALLING_SPEED*fallSpeed:
			velocity.y = MAX_FALLING_SPEED*fallSpeed

# These next two functions handle the shooting. This first one detects the direction of the input

func _shooting(delta):
	if shootingCooldown > 0:
		shootingCooldown -= delta
	
	var stick = Vector2(Input.get_joy_axis(0, JOY_ANALOG_RX), Input.get_joy_axis(0, JOY_ANALOG_RY))
	if stick.length() > 0.2:
		shootingDirection = stick
	if Input.is_action_pressed("ui_shoot_1"):
		_shoot()
	
	if Input.is_action_pressed("ui_mouse_left_click"):
		shootingDirection = get_viewport().get_mouse_position()
		shootingDirection = Vector2(shootingDirection.x - self.get_global_transform_with_canvas().origin.x, shootingDirection.y - self.get_global_transform_with_canvas().origin.y)
		_shoot()

func _shoot():
	if shootingCooldown <= 0:
		shootingCooldown = RATE_OF_FIRE / 1000
		var parent = get_parent()
		var projectile = bullet.instance()
		parent.add_child(projectile)
		projectile.position = position
		projectile.direction = shootingDirection.normalized()

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
	if area.is_in_group("ledge") and leftWall > 0:
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
	if area.is_in_group("ledge") and rightWall > 0:
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

# These detectors are for detecting ground. They are better than is_on_floor() because they only detect nodes on the 'floor'
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

# These second ground detectors are for the early jump. If they touch floor from which the player can jump off, it allows
# the player to press the jump button and initiate a jump the moment they touch the floor, if they are still pressing it.
# This allows for much easier consecutive jumps.

func _on_down2_body_entered(body):
	if body.is_in_group("floor"):
		touchFloor2 += 1

func _on_down2_body_exited(body):
	if body.is_in_group("floor"):
		touchFloor2 -= 1

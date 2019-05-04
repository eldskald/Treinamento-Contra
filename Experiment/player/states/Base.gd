extends State




func _ready():
	self.this_state = BASE_STATE
	player.max_falling_speed = player.base_falling_speed
	$EarlyJumpTimer.wait_time = player.early_jump_time
	$CoyoteJumpTimer.wait_time = player.coyote_jump_time

func _physics_process(_delta):
	
	move_player()
	jump()
	early_jump()
	coyote_jump()
	




func move_player() -> void:
	player.move = player.directional_input_actual.x


func jump():
	if Input.is_action_just_pressed("ui_jump") and player.is_touching_floor():
		player.velocity.y = -player.jump_force
		player.is_jumping = true
	elif player.is_jumping and Input.is_action_just_released("ui_jump"):
		player.velocity.y = 0
		player.is_jumping = false
	elif player.is_jumping and player.velocity.y >= 0:
		player.is_jumping = false
	elif player.is_jumping and not player.is_airborne():
		player.is_jumping = false


func early_jump() -> void:
	if not player.is_touching_floor() and Input.is_action_just_pressed("ui_jump"):
		$EarlyJumpTimer.start()
	elif player.is_touching_floor() and not $EarlyJumpTimer.is_stopped() and Input.is_action_pressed("ui_jump"):
		$EarlyJumpTimer.stop()
		player.is_jumping = true
		player.velocity.y = -player.jump_force
	elif not $EarlyJumpTimer.is_stopped() and not Input.is_action_pressed("ui_jump"):
		$EarlyJumpTimer.stop()


func coyote_jump() -> void:
	if not player.is_touching_floor() and not player.is_jumping:
		$CoyoteJumpTimer.start()
	if not $CoyoteJumpTimer.is_stopped() and Input.is_action_just_pressed("ui_jump"):
		$CoyoteJumpTimer.stop()
		player.is_jumping = true
		player.velocity.y = -player.jump_force
	if player.is_touching_floor() and not $CoyoteJumpTimer.is_stopped():
		$CoyoteJumpTimer.stop()

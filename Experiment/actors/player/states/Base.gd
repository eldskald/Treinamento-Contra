extends State

onready var can_coyote_jump: bool = false


func _ready():
	self.this_state = BASE_STATE
	player.gravity = player.base_gravity
	player.max_natural_speed = player.move_speed
	player.acceleration = player.base_acceleration
	player.jump_force = player.base_jump_force
	player.max_falling_speed = player.base_falling_speed
	player.max_rising_speed = MAX_SPEED
	$EarlyJumpTimer.wait_time = player.early_jump_time
	$CoyoteJumpTimer.wait_time = player.coyote_jump_time

func _physics_process(_delta):
	
	if not player.is_wall_jumping:
		move_player()
	
	if not player.is_airborne():
		player.can_dodge = true
	
	jump()
	early_jump()
	coyote_jump()
	
	gliding()
	diving()
	
	cling_to_walls_and_ledges()
	
	healing()




##### This method handles moving the player ###############################
func move_player() -> void:
	player.move = player.directional_input_actual.x
	if player.move != 0:
		player.facing = player.move/abs(player.move)
###########################################################################



##### These methods handle the basic jump #################################
func jump():
	if Input.is_action_just_pressed("ui_jump") and player.on_floor():
		player.velocity.y = -player.jump_force
		player.is_jumping = true
	elif player.is_jumping and Input.is_action_just_released("ui_jump"):
		player.velocity.y = 0
		player.is_jumping = false
		player.is_wall_jumping = false
	elif player.is_jumping and player.velocity.y >= 0:
		player.is_jumping = false
		player.is_wall_jumping = false
	if player.is_wall_jumping and ((player.facing == 1.0 and not player.close_to_left_wall()) or (player.facing == -1.0 and not player.close_to_right_wall())):
		if player.directional_input_actual.x != player.facing:
			player.is_wall_jumping = false

# This makes jumping right after landing feel better.
func early_jump() -> void:
	if not player.on_floor() and Input.is_action_just_pressed("ui_jump"):
		$EarlyJumpTimer.start()
	elif player.on_floor() and not $EarlyJumpTimer.is_stopped() and Input.is_action_pressed("ui_jump"):
		$EarlyJumpTimer.stop()
		player.is_jumping = true
		player.velocity.y = -player.jump_force
	elif not $EarlyJumpTimer.is_stopped() and not Input.is_action_pressed("ui_jump"):
		$EarlyJumpTimer.stop()

# This makes jumping off of ledges feel better.
func coyote_jump() -> void:
	if player.on_floor():
		can_coyote_jump = true
	elif not player.on_floor() and player.is_jumping:
		can_coyote_jump = false
	
	if not player.on_floor() and not player.is_jumping and can_coyote_jump:
		$CoyoteJumpTimer.start()
		can_coyote_jump = false
	if not $CoyoteJumpTimer.is_stopped() and Input.is_action_just_pressed("ui_jump"):
		$CoyoteJumpTimer.stop()
		player.is_jumping = true
		player.velocity.y = -player.jump_force
###########################################################################



##### These methods transition to gliding and diving states ###############
func gliding() -> void:
	if Input.is_action_pressed("ui_jump") and player.is_airborne() and not player.is_jumping:
		player.change_state(GLIDING_STATE)

func diving() -> void:
	if Input.is_action_just_pressed("ui_jump") and player.is_airborne() and player.directional_input_actual.y == 1:
		player.change_state(DIVING_STATE)
###########################################################################



##### These methods handles climbing and hanging from ledges ##############
func cling_to_walls_and_ledges() -> void:
	if not player.on_floor() and player.on_any_wall():
		if player.on_any_ledge():
			deal_with_ledges()
		else:
			player.change_state(WALL_CLINGING_STATE)

func deal_with_ledges() -> void:
	var ledge = player.find_left_ledge()
	if ledge == null:
		ledge = player.find_left_ledge()
	if player.position.y - ledge.position.y >= 2:
			player.position.y = ledge.position.y + 16
			player.change_state(LEDGE_HANGING_STATE)
	else:
		player.change_state(LEDGE_JUMPING_STATE)
###########################################################################



##### This method handles the usage of health packs #######################
func healing() -> void:
	if player.on_floor() and Input.is_action_pressed("ui_heal"):
		player.change_state(HEALING_STATE)
###########################################################################

extends PlayerState



func _ready():
	self.this_state = WALL_CLINGING_STATE
	player.max_falling_speed = player.wall_sliding_speed
	player.move = 0.0
	player.is_wall_jumping = false
	
	if player.on_left_wall():
		player.facing = 1.0
	elif player.on_right_wall():
		player.facing = -1.0

func _physics_process(_delta):
	wall_jumping()
	letting_go()


func wall_jumping() -> void:
	if Input.is_action_just_pressed("ui_jump") or (player.directional_input_actual.x == player.facing and player.directional_input_old.x != player.facing):
		player.is_jumping = true
		player.is_wall_jumping = true
		player.velocity = Vector2( player.facing*player.move_speed , -player.wall_jump_multiplier*player.jump_force)
		player.move = player.facing


func letting_go() -> void:
	if player.directional_input_actual == Vector2(0,1) and player.directional_input_old != Vector2(0,1):
		player.position.x += player.facing*5
	
	if not player.on_any_wall() or player.on_floor():
		player.change_state(BASE_STATE)


extends PlayerState



var ledge

func _ready():
	self.this_state = LEDGE_HANGING_STATE
	player.gravity = 0.0
	player.velocity = Vector2(0,0)
	
	ledge = player.find_left_ledge()
	player.facing = 1.0
	if ledge == null:
		ledge = player.find_right_ledge()
		player.facing = -1.0


func _physics_process(_delta):
	climbing()
	wall_jumping()
	letting_go()


func climbing() -> void:
	if player.directional_input_actual.x >= -player.facing and player.directional_input_actual.y <= 0  and player.directional_input_actual != Vector2(0,0) and player.directional_input_old != player.directional_input_actual:
		player.change_state(LEDGE_JUMPING_STATE)


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


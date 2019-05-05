extends State



func _ready():
	self.this_state = GLIDING_STATE
	player.max_falling_speed = player.gliding_speed

func _physics_process(_delta):
	
	move_player()
	stop_gliding()



func move_player() -> void:
	player.move = player.directional_input_actual.x
	if player.move != 0:
		player.facing = player.move/abs(player.move)

func stop_gliding() -> void:
	if Input.is_action_just_released("ui_jump") or player.on_floor():
		player.change_state(BASE_STATE)
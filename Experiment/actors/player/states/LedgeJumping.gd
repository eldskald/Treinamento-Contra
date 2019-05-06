extends State



var ledge
var can_end_animation

func _ready():
	self.this_state = LEDGE_JUMPING_STATE
	player.gravity = player.base_gravity
	player.max_natural_speed = player.move_speed
	player.acceleration = player.base_acceleration
	player.jump_force = player.base_jump_force
	player.max_falling_speed = player.base_falling_speed
	player.max_rising_speed = MAX_SPEED
	
	ledge = player.find_left_ledge()
	player.facing = 1.0
	if ledge == null:
		ledge = player.find_right_ledge()
		player.facing = -1.0
	
	player.velocity = Vector2(0, -400)
	player.move = -player.facing
	can_end_animation = false


func _physics_process(_delta):
	if player.velocity.y >= 0 and not can_end_animation:
		can_end_animation = true
	
	if can_end_animation and (player.directional_input_actual != Vector2(0,0) or player.on_floor()):
		player.change_state(BASE_STATE)
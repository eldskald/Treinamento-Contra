extends State




func _ready():
	self.this_state = DIVING_STATE
	player.move = 0.0
	player.max_falling_speed = player.diving_speed
	player.velocity = Vector2(0, player.diving_speed)


func _physics_process(_delta):
	if not player.is_airborne():
		player.change_state(BASE_STATE)
extends State



onready var dodge_speed = player.dodge_distance / player.dodge_time

func _ready():
	self.this_state = DODGING_STATE
	player.max_falling_speed = dodge_speed
	player.max_natural_speed = dodge_speed
	player.gravity = 0.0
	player.acceleration = 0.0
	
	
	$Timer.wait_time = player.dodge_time
	player.set_collision_layer(2)
	player.set_collision_mask(2)
	player.can_dodge = false
	$Timer.start()

func _physics_process(_delta):
	player.velocity = dodge_speed * player.dodge_direction.normalized()
	player.move = player.dodge_direction.x


func _on_Timer_timeout():
	player.velocity = Vector2(0,0)
	player.set_collision_layer(1)
	player.set_collision_mask(1)
	player.change_state(BASE_STATE)

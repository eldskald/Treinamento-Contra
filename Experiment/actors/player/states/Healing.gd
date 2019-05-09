extends PlayerState



func _ready():
	self.this_state = HEALING_STATE
	$Timer.wait_time = player.healing_time
	$Timer.start()

func _physics_process(_delta):
	stop_healing()



func stop_healing() -> void:
	if Input.is_action_just_released("ui_heal"):
		player.change_state(BASE_STATE)


func _on_Timer_timeout():
	player.current_hp = player.hit_points
	player.packs_available -= 1
	player.get_node("Finder").get("hud").update_display()
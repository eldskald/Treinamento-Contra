extends Control



onready var game_paused = false
var child

func _physics_process(_delta):
	
	# Pausing the game and opening the menu.
	
	if game_paused == false:
		if Input.is_action_just_pressed("ui_start") or Input.is_action_just_pressed("ui_select"):
			get_tree().set_pause(true)
			game_paused = true
			child = preload("res://ui/Pause Menu.tscn").instance()
			add_child(child)

# This function is called from the player as a signal to update the display of hearts and health packs.

func update_display (hearts, current_hit_points, max_packs, current_packs):
	for x in $Hearts.get_children():
		x.queue_free()
	for i in range(hearts):
		if current_hit_points <= 2*i:
			child = preload("res://assets/textures/ui elements/EmptyHeart.tscn").instance()
		elif current_hit_points == 2*i + 1:
			child = preload("res://assets/textures/ui elements/HalfHeart.tscn").instance()
		elif current_hit_points >= 2*(i+1):
			child = preload("res://assets/textures/ui elements/FullHeart.tscn").instance()
		$Hearts.add_child(child)
		
	for x in $HealthPacks.get_children():
		x.queue_free()
	for i in range(max_packs):
		if current_packs > i:
			child = preload("res://assets/textures/ui elements/FilledPack.tscn").instance()
		elif current_packs <= i:
			child = preload("res://assets/textures/ui elements/UsedPack.tscn").instance()
		$HealthPacks.add_child(child)
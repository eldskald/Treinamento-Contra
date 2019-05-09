extends Control



onready var game_paused = false
var child

func _physics_process(_delta):
	
	# Pausing the game and opening the menu.
	if game_paused == false:
		if Input.is_action_just_pressed("ui_start") or Input.is_action_just_pressed("ui_select"):
			get_tree().set_pause(true)
			game_paused = true
			child = preload("res://hud/Pause Menu.tscn").instance()
			add_child(child)



# This function updates the display of hearts and health packs. Can be called with by finding the
# HUD with a Locator and updating directly from whoever wants to update.
func update_display () -> void:
	var player = $Finder.get("player")
	var hearts = player.hit_points/2
	
	# Updating hearts display.
	for x in $Hearts.get_children():
		x.queue_free()
	for i in range(hearts):
		if player.current_hp <= 2*i:
			child = preload("res://assets/textures/ui elements/EmptyHeart.tscn").instance()
		elif player.current_hp == 2*i + 1:
			child = preload("res://assets/textures/ui elements/HalfHeart.tscn").instance()
		elif player.current_hp >= 2*(i+1):
			child = preload("res://assets/textures/ui elements/FullHeart.tscn").instance()
		$Hearts.add_child(child)
	
	# Updating health packs display.
	for x in $HealthPacks.get_children():
		x.queue_free()
	for i in range(player.total_health_packs):
		if player.packs_available > i:
			child = preload("res://assets/textures/ui elements/FilledPack.tscn").instance()
		elif player.packs_available <= i:
			child = preload("res://assets/textures/ui elements/UsedPack.tscn").instance()
		$HealthPacks.add_child(child)
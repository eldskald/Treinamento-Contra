extends Control

var gamePaused = false
var child

func _physics_process(delta):
	
	# Pausing the game and opening the menu.
	
	if gamePaused == false:
		if Input.is_action_just_pressed("ui_start") or Input.is_action_just_pressed("ui_select"):
			get_tree().set_pause(true)
			gamePaused = true
			child = preload("res://prefabs/Pause Menu.tscn").instance()
			add_child(child)

# This function is called from the player as a signal to update the display of hearts and health packs.

func _on_update_hearts (hearts, currentHitPoints, maxPacks, currentPacks):
	for x in $Hearts.get_children():
		x.queue_free()
	for i in range(hearts):
		if currentHitPoints <= 2*i:
			child = preload("res://prefabs/UI Elements/Empty Heart.tscn").instance()
		elif currentHitPoints == 2*i + 1:
			child = preload("res://prefabs/UI Elements/Half Heart.tscn").instance()
		elif currentHitPoints >= 2*(i+1):
			child = preload("res://prefabs/UI Elements/Full Heart.tscn").instance()
		$Hearts.add_child(child)
		
	for x in $"Health Packs".get_children():
		x.queue_free()
	for i in range(maxPacks):
		if currentPacks > i:
			child = preload("res://prefabs/UI Elements/Filled Pack.tscn").instance()
		elif currentPacks <= i:
			child = preload("res://prefabs/UI Elements/Used Pack.tscn").instance()
		$"Health Packs".add_child(child)
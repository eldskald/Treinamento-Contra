extends Control

var submenuOpened = false
var submenu

func _physics_process(delta):
	
	# Unpausing.
	if Input.is_action_just_pressed("ui_start") or Input.is_action_just_pressed("ui_select"):
			get_tree().set_pause(false)
			get_parent().gamePaused = false
			self.queue_free()
	
	# Closing opened submenus.
	if Input.is_action_just_pressed("ui_cancel"):
		if submenuOpened:
			for menu in $Menus.get_children():
				if menu.name != "Main Menu":
					menu.queue_free()
			submenuOpened = false
		else:
			get_tree().set_pause(false)
			get_parent().gamePaused = false
			self.queue_free()

func _on_resume_pressed():
	get_tree().set_pause(false)
	get_parent().gamePaused = false
	self.queue_free()

func _on_quit_pressed():
	get_tree().quit()

func _on_controls_pressed():
	submenu = preload("res://prefabs/UI Elements/Controls Menu.tscn").instance()
	$Menus.add_child(submenu)
	submenuOpened = true

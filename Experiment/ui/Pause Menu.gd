extends Control

var submenuOpened = false
var submenu
var tooltip
var controlsSubmenu = false

#warning-ignore:unused_argument
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
			if tooltip != null:
				tooltip.queue_free()
			submenuOpened = false
			controlsSubmenu = false
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
	if !controlsSubmenu:
		submenu = preload("res://prefabs/UI Elements/Controls Menu.tscn").instance()
		$Menus.add_child(submenu)
		submenu.get_node("Scheme 1").connect("pressed", self, "_on_controls_1_pressed")
		submenu.get_node("Scheme 1").connect("mouse_entered", self, "_on_controls_1_entered")
		submenu.get_node("Scheme 1").connect("mouse_exited", self, "_on_controls_all_exited")
		submenu.get_node("Scheme 2").connect("pressed", self, "_on_controls_2_pressed")
		submenu.get_node("Scheme 2").connect("mouse_entered", self, "_on_controls_2_entered")
		submenu.get_node("Scheme 2").connect("mouse_exited", self, "_on_controls_all_exited")
		submenu.get_node("Scheme 3").connect("pressed", self, "_on_controls_3_pressed")
		submenu.get_node("Scheme 3").connect("mouse_entered", self, "_on_controls_3_entered")
		submenu.get_node("Scheme 3").connect("mouse_exited", self, "_on_controls_all_exited")
		submenu.get_node("Scheme 4").connect("pressed", self, "_on_controls_4_pressed")
		submenu.get_node("Scheme 4").connect("mouse_entered", self, "_on_controls_4_entered")
		submenu.get_node("Scheme 4").connect("mouse_exited", self, "_on_controls_all_exited")
		submenuOpened = true
		controlsSubmenu = true
	else:
		for menu in $Menus.get_children():
			if menu.name != "Main Menu":
				menu.queue_free()
		if tooltip != null:
			tooltip.queue_free()
			tooltip = null
		submenuOpened = false
		controlsSubmenu = false

func _on_controls_1_pressed():
	pass

func _on_controls_1_entered():
	tooltip = preload("res://prefabs/UI Elements/ControlsTooltip1.tscn").instance()
	add_child(tooltip)

func _on_controls_2_pressed():
	pass

func _on_controls_2_entered():
	tooltip = preload("res://prefabs/UI Elements/ControlsTooltip2.tscn").instance()
	add_child(tooltip)

func _on_controls_3_pressed():
	pass

func _on_controls_3_entered():
	tooltip = preload("res://prefabs/UI Elements/ControlsTooltip3.tscn").instance()
	add_child(tooltip)

func _on_controls_4_pressed():
	pass

func _on_controls_4_entered():
	tooltip = preload("res://prefabs/UI Elements/ControlsTooltip4.tscn").instance()
	add_child(tooltip)

func _on_controls_all_exited():
	if tooltip != null:
		tooltip.queue_free()
		tooltip = null

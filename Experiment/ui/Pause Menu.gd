extends Control

onready var submenu_opened = false
onready var controls_submenu = false
onready var locator = Locator.new(get_tree())

var submenu
var tooltip

#warning-ignore:unused_argument
func _physics_process(delta):
	
	# Unpausing.
	if Input.is_action_just_pressed("ui_start") or Input.is_action_just_pressed("ui_select"):
			get_tree().set_pause(false)
			get_parent().game_paused = false
			self.queue_free()
	
	# Closing opened submenus.
	if Input.is_action_just_pressed("ui_cancel"):
		if submenu_opened:
			for menu in $Menus.get_children():
				if menu.name != "Main Menu":
					menu.queue_free()
			if tooltip != null:
				tooltip.queue_free()
			submenu_opened = false
			controls_submenu = false
		else:
			get_tree().set_pause(false)
			get_parent().game_paused = false
			self.queue_free()

func _on_Resume_pressed():
	get_tree().set_pause(false)
	get_parent().game_paused = false
	self.queue_free()

func _on_Quit_pressed():
	get_tree().quit()

func _on_Controls_pressed():
	if not controls_submenu:
		submenu = preload("res://ui/Controls Menu.tscn").instance()
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
		submenu_opened = true
		controls_submenu = true
	else:
		for menu in $Menus.get_children():
			if menu.name != "Main Menu":
				menu.queue_free()
		if tooltip != null:
			tooltip.queue_free()
			tooltip = null
		submenu_opened = false
		controls_submenu = false

func _on_controls_1_pressed():
	var main = locator.find_entity("main")
	main.change_mouse_and_keyboard(1)

func _on_controls_1_entered():
	tooltip = preload("res://assets/textures/ui elements/ControlsTooltip2.tscn").instance()
	add_child(tooltip)

func _on_controls_2_pressed():
	var main = locator.find_entity("main")
	main.change_mouse_and_keyboard(2)

func _on_controls_2_entered():
	tooltip = preload("res://assets/textures/ui elements/ControlsTooltip3.tscn").instance()
	add_child(tooltip)

func _on_controls_3_pressed():
	var main = locator.find_entity("main")
	main.change_mouse_and_keyboard(3)

func _on_controls_3_entered():
	tooltip = preload("res://assets/textures/ui elements/ControlsTooltip4.tscn").instance()
	add_child(tooltip)

func _on_controls_all_exited():
	if tooltip != null:
		tooltip.queue_free()
		tooltip = null


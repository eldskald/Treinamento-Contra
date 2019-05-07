extends Node


# Control settings for mouse and keyboard.

onready var mouse_and_keyboard: int = 1
onready var controller: int = 1

func change_mouse_and_keyboard(new_scheme) -> void:
	var mouse = InputEventMouseButton.new()
	var key = InputEventKey.new()
	
	##### Removing Scheme 1 ################################################
	if mouse_and_keyboard == 1:
		
		key.scancode = KEY_SPACE
		InputMap.action_erase_event("ui_jump", key)
		
		mouse.button_index = BUTTON_RIGHT
		InputMap.action_erase_event("ui_dodge", mouse)
		
		key.scancode = KEY_SHIFT
		InputMap.action_erase_event("ui_dodge", key)
		
		mouse.button_index = BUTTON_LEFT
		InputMap.action_erase_event("ui_shoot", mouse)
	########################################################################
		
	##### Removing Scheme 2 ################################################
	elif mouse_and_keyboard == 2:
		
		mouse.button_index = BUTTON_RIGHT
		InputMap.action_erase_event("ui_jump", mouse)
		
		key.scancode = KEY_SHIFT
		InputMap.action_erase_event("ui_jump", key)
		
		key.scancode = KEY_SPACE
		InputMap.action_erase_event("ui_dodge", key)
		
		mouse.button_index = BUTTON_LEFT
		InputMap.action_erase_event("ui_shoot", mouse)
	########################################################################
		
	##### Removing Scheme 3 ################################################
	elif mouse_and_keyboard == 3:
		
		mouse.button_index = BUTTON_RIGHT
		InputMap.action_erase_event("ui_jump", mouse)
		
		mouse.button_index = BUTTON_LEFT
		InputMap.action_erase_event("ui_dodge", mouse)
		
		key.scancode = KEY_SHIFT
		InputMap.action_erase_event("ui_dodge", key)
		
		key.scancode = KEY_SPACE
		InputMap.action_erase_event("ui_shoot", key)
	########################################################################
		
	
	mouse_and_keyboard = new_scheme
	
	##### Implementing Scheme 1 ############################################
	if mouse_and_keyboard == 1:
		
		key.scancode = KEY_SPACE
		InputMap.action_add_event("ui_jump", key)
		
		mouse.button_index = BUTTON_RIGHT
		InputMap.action_add_event("ui_dodge", mouse)
		
		key.scancode = KEY_SHIFT
		InputMap.action_add_event("ui_dodge", key)
		
		mouse.button_index = BUTTON_LEFT
		InputMap.action_add_event("ui_shoot", mouse)
	########################################################################
		
	##### Implementing Scheme 2 ############################################
	elif mouse_and_keyboard == 2:
		
		mouse.button_index = BUTTON_RIGHT
		InputMap.action_add_event("ui_jump", mouse)
		
		key.scancode = KEY_SHIFT
		InputMap.action_add_event("ui_jump", key)
		
		key.scancode = KEY_SPACE
		InputMap.action_add_event("ui_dodge", key)
		
		mouse.button_index = BUTTON_LEFT
		InputMap.action_add_event("ui_shoot", mouse)
	########################################################################
		
	##### Implementing Scheme 3 ############################################
	elif mouse_and_keyboard == 3:
		
		mouse.button_index = BUTTON_RIGHT
		InputMap.action_add_event("ui_jump", mouse)
		
		mouse.button_index = BUTTON_LEFT
		InputMap.action_add_event("ui_dodge", mouse)
		
		key.scancode = KEY_SHIFT
		InputMap.action_add_event("ui_dodge", key)
		
		key.scancode = KEY_SPACE
		InputMap.action_add_event("ui_shoot", key)
	########################################################################
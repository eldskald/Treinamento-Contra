extends BaseCreature

const joystick_deadzone: float = 0.2

export(int) var hearts
export(int) var health_packs

onready var directional_input_actual = Vector2()
onready var directional_input_old = Vector2()


func get_and_update_directional_input() -> void:
	directional_input_old = directional_input_actual
	directional_input_actual - Vector2()
	
	####################Getting from diretion buttons ####################
	directional_input_actual = Vector2(
		Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up"))
	#######################################################################
	
	###################Getting from joystick###############################
	var stick_input = Vector2(
		Input.get_joy_axis(0, JOY_ANALOG_LX), 
		Input.get_joy_axis(0, JOY_ANALOG_LY))
	if abs(stick_input.x) >= joystick_deadzone:
		directional_input_actual.x = abs(stick_input.x)/stick_input.x
	if abs(stick_input.y) >= joystick_deadzone:
		directional_input_actual.y = abs(stick_input.y)/stick_input.y
	###################Tests Required###################################


func is_holding_a_horizontal_input() -> bool:
	return directional_input_actual == directional_input_old

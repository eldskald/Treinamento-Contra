extends BaseCreature



const THUMBSTICK_DEADZONE: float = 0.2
const BASE_STATE: int = 0
const WALL_CLINGING_STATE: int = 1
const LEDGE_HANGING_STATE: int = 2
const LEDGE_JUMPING_STATE: int = 3
const DIVING_STATE: int = 4
const DODGING_STATE: int = 5



export(float) var move_speed
export(float) var base_acceleration
export(float) var base_gravity
export(float) var jump_height
# warning-ignore:unused_class_variable
export(float) var gliding_speed
# warning-ignore:unused_class_variable
export(float) var diving_speed
# warning-ignore:unused_class_variable
export(float) var wall_sliding_speed
# warning-ignore:unused_class_variable
export(float) var dodge_distance
# warning-ignore:unused_class_variable
export(float) var dodge_time
# warning-ignore:unused_class_variable
export(float) var early_jump_time
# warning-ignore:unused_class_variable
export(float) var coyote_jump_time



onready var directional_input_actual := Vector2()
onready var directional_input_old := Vector2()
onready var base_jump_force: float = sqrt(2*jump_height*base_gravity)
onready var base_falling_speed: float = sqrt(2*jump_height*base_gravity)
# warning-ignore:unused_class_variable
onready var is_jumping: bool = false
# warning-ignore:unused_class_variable
onready var is_wall_jumping: bool = false



func _ready():
	self.gravity = base_gravity
	self.max_natural_speed = move_speed
	self.acceleration = base_acceleration
	self.jump_force = base_jump_force
	self.max_falling_speed = base_falling_speed
	self.forced_velocity = 0
	change_state(BASE_STATE)



func _physics_process(_delta):
	get_directional_inputs()
	
	print(is_touching_floor())


# This function checks if the player is pressing any directional button or tilting the left analog stick.
# It takes care of diagonals, opposing directional inputs and everything, from both the buttons and the stick.
func get_directional_inputs() -> void:
	directional_input_old = directional_input_actual
	
	################### Getting from diretional buttons #####################
	directional_input_actual = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up"))
	#########################################################################
	
	################### Getting from thumbsticks ############################
	var stick_input = Vector2(
		Input.get_joy_axis(0, JOY_ANALOG_LX), 
		Input.get_joy_axis(0, JOY_ANALOG_LY))
	if abs(stick_input.x) >= THUMBSTICK_DEADZONE:
		directional_input_actual.x = abs(stick_input.x)/stick_input.x
	if abs(stick_input.y) >= THUMBSTICK_DEADZONE:
		directional_input_actual.y = abs(stick_input.y)/stick_input.y
	################### Tests Required ######################################


# This method returns the current state.
func get_state() -> int:
	for state in $State.get_children():
		return state.this_state


# This method is used to switch states.
func change_state(new_state):
	for state in $State.get_children():
		state.queue_free()
	if new_state == BASE_STATE:
		new_state = preload("res://player/states/Base.tscn").instance()
		$State.add_child(new_state)
	elif new_state == WALL_CLINGING_STATE:
		new_state = preload("res://player/states/WallClinging.tscn").instance()
		$State.add_child(new_state)
	elif new_state == LEDGE_HANGING_STATE:
		new_state = preload("res://player/states/LedgeHanging.tscn").instance()
		$State.add_child(new_state)
	elif new_state == LEDGE_JUMPING_STATE:
		new_state = preload("res://player/states/LedgeJumping.tscn").instance()
		$State.add_child(new_state)
	elif new_state == DIVING_STATE:
		new_state = preload("res://player/states/Diving.tscn").instance()
		$State.add_child(new_state)
	elif new_state == DODGING_STATE	:
		new_state = preload("res://player/states/Dodging.tscn").instance()
		$State.add_child(new_state)

# Methods to check if the player is on the floor, touching a wall, etc.
func is_touching_floor() -> bool:
	var i = 0
	for body in get_down_bodies():
		if body.is_in_group("floor"):
			i += 1
	if i > 0:
		return true
	else:
		return false
func is_touching_left_wall() -> bool:
	var i = 0
	for body in get_left_bodies():
		if body.is_in_group("wall"):
			i += 1
	if i > 0:
		return true
	else:
		return false
func is_touching_right_wall() -> bool:
	var i = 0
	for body in get_right_bodies():
		if body.is_in_group("wall"):
			i += 1
	if i > 0:
		return true
	else:
		return false
func is_airborne() -> bool:
	return !is_touching_floor() and !is_touching_left_wall() and !is_touching_right_wall()

# These two functions use the larger, second wall detectors. Used on the wall jump feature.
func is_close_to_left_wall() -> bool:
	var i = 0
	for body in $Detectors/LeftWall.get_overlapping_bodies():
		if body.is_in_group("wall"):
			i += 1
	if i > 0:
		return true
	else:
		return false
func is_close_to_right_wall() -> bool:
	var i = 0
	for body in $Detectors/RightWall.get_overlapping_bodies():
		if body.is_in_group("wall"):
			i += 1
	if i > 0:
		return true
	else:
		return false





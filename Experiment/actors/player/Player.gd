extends BaseCreature



const THUMBSTICK_DEADZONE: float = 0.2
const BASE_STATE: int = 0
const WALL_CLINGING_STATE: int = 1
const LEDGE_HANGING_STATE: int = 2
const LEDGE_JUMPING_STATE: int = 3
const GLIDING_STATE: int = 4
const DIVING_STATE: int = 5
const DODGING_STATE: int = 6
const HEALING_STATE: int = 7



export(float) var move_speed
export(float) var base_acceleration
export(float) var base_gravity
export(float) var jump_height
# warning-ignore:unused_class_variable
export(float) var gliding_speed
# warning-ignore:unused_class_variable
export(float) var diving_speed
# warning-ignore:unused_class_variable
export(float) var wall_jump_multiplier
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
# warning-ignore:unused_class_variable
export(int) var total_health_packs
# warning-ignore:unused_class_variable
export(float) var healing_time
export(float) var invincibility_time


onready var directional_input_actual := Vector2()
onready var directional_input_old := Vector2()
onready var base_jump_force: float = sqrt(2*jump_height*base_gravity)
onready var base_falling_speed: float = sqrt(2*jump_height*base_gravity)
onready var can_dodge: bool = false
onready var dodge_direction := Vector2()
# warning-ignore:unused_class_variable
onready var is_jumping: bool = false
# warning-ignore:unused_class_variable
onready var is_wall_jumping: bool = false
# warning-ignore:unused_class_variable
onready var facing: float = 1.0
# warning-ignore:unused_class_variable
onready var packs_available: int = total_health_packs
# warning-ignore:unused_class_variable
onready var stagger_direction: int = 0



func _ready():
	self.gravity = base_gravity
	self.max_natural_speed = move_speed
	self.acceleration = base_acceleration
	self.jump_force = base_jump_force
	self.max_falling_speed = base_falling_speed
	self.max_rising_speed = MAX_SPEED
	self.forced_velocity = 0
	$InvincibilityTimer.wait_time = invincibility_time
	change_state(BASE_STATE)
	
	$Finder.get("hud").update_display()



func _physics_process(_delta):
	get_directional_inputs()
	
	if can_dodge and Input.is_action_just_pressed("ui_dodge"):
		dodging()


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
	#########################################################################


# This method returns the current state.
func get_state() -> int:
	for state in $State.get_children():
		return state.this_state

# This method is used to switch states.
func change_state(new_state):
	for state in $State.get_children():
		state.queue_free()
	if new_state == BASE_STATE:
		new_state = preload("res://actors/player/states/Base.tscn").instance()
		$State.add_child(new_state)
	elif new_state == WALL_CLINGING_STATE:
		new_state = preload("res://actors/player/states/WallClinging.tscn").instance()
		$State.add_child(new_state)
	elif new_state == LEDGE_HANGING_STATE:
		new_state = preload("res://actors/player/states/LedgeHanging.tscn").instance()
		$State.add_child(new_state)
	elif new_state == LEDGE_JUMPING_STATE:
		new_state = preload("res://actors/player/states/LedgeJumping.tscn").instance()
		$State.add_child(new_state)
	elif new_state == GLIDING_STATE:
		new_state = preload("res://actors/player/states/Gliding.tscn").instance()
		$State.add_child(new_state)
	elif new_state == DIVING_STATE:
		new_state = preload("res://actors/player/states/Diving.tscn").instance()
		$State.add_child(new_state)
	elif new_state == DODGING_STATE:
		new_state = preload("res://actors/player/states/Dodging.tscn").instance()
		$State.add_child(new_state)
	elif new_state == HEALING_STATE:
		new_state = preload("res://actors/player/states/Healing.tscn").instance()
		$State.add_child(new_state)



# Dodging feature. If dodge_direction is zero, the player won't dodge. Otherwise, it will dodge
# to the direction the player is facing or the directional inputs the player is giving.
func dodging() -> void:
	var state = get_state()
	
	################### Getting from diretional inputs #####################
	if state == BASE_STATE or state == GLIDING_STATE or state == LEDGE_JUMPING_STATE or state == HEALING_STATE:
		if directional_input_actual != Vector2(0,0):
			dodge_direction = directional_input_actual
		else:
			dodge_direction = Vector2(facing , 0)
	########################################################################
	
	################### Getting from facing only ###########################
	elif state == WALL_CLINGING_STATE or state == LEDGE_HANGING_STATE:
		dodge_direction = Vector2(facing , 0)
	########################################################################
	
	################### Can't dodge on these states ########################
	else:
		dodge_direction = Vector2(0,0)
	########################################################################
	
	if dodge_direction != Vector2(0,0):
		change_state(DODGING_STATE)



# Invincibility feature. When the player takes damage, the player becomes invincible for
# invincibility_time amount of seconds, set on the export. No knockback. The source_direction
# vector is used to determine if the player is bouncing off of a bounceable bullet.
func take_damage(damage_amount: int, source_direction = Vector2()) -> void:
	if interval(source_direction.angle(), 3*PI/4, PI/4) and has_bounceable_projectile_underneath():
		if get_state() == DIVING_STATE:
			bounce()
		elif get_state() == BASE_STATE:
			var timer = get_node("State/Base/EarlyJumpTimer")
			if not timer.is_stopped:
				bounce()
		else:
			got_hit(damage_amount)
	else:
		got_hit(damage_amount)

func bounce() -> void:
	self.velocity.y -= jump_force
	is_jumping = true
	can_dodge = true

func got_hit(damage_amount: int) -> void:
	if not is_invincible():
		self.current_hp -= damage_amount
		$InvincibilityTimer.start()
		$Finder.get("hud").update_display()

func is_invincible() -> bool:
	return not $InvincibilityTimer.is_stopped()

func has_bounceable_projectile_underneath() -> bool:
	for area in self.get_down_areas():
		if area.is_in_group("bounceable"):
			return true
	return false



# Methods to check if the player is on the floor, touching a wall, etc.
func on_floor() -> bool:
	for body in get_down_bodies():
		if body.is_in_group("floor"):
			return true
	return false

func on_left_wall() -> bool:
	for body in get_left_bodies():
		if body.is_in_group("wall"):
			return true
	return false

func on_right_wall() -> bool:
	for body in get_right_bodies():
		if body.is_in_group("wall"):
			return true
	return false

func on_any_wall() -> bool:
	return on_left_wall() or on_right_wall()
func is_airborne() -> bool:
	return not on_floor() and not on_any_wall()



# These next methods find and return ledges the player is touching.
func find_left_ledge() -> Node:
	for area in get_left_areas():
		if area.is_in_group("ledge"):
			return area
	return null

func find_right_ledge() -> Node:
	for area in get_right_areas():
		if area.is_in_group("ledge"):
			return area
	return null



# This method returns true if the player is touching a ledge on either side.
func on_any_ledge() -> bool:
	if find_left_ledge() != null or find_right_ledge() != null:
		return true
	else:
		return false



# These two functions use the larger, second wall detectors. Used on the wall jump feature.
func close_to_left_wall() -> bool:
	var i = 0
	for body in $Detectors/LeftWall.get_overlapping_bodies():
		if body.is_in_group("wall"):
			i += 1
	if i > 0:
		return true
	else:
		return false

func close_to_right_wall() -> bool:
	var i = 0
	for body in $Detectors/RightWall.get_overlapping_bodies():
		if body.is_in_group("wall"):
			i += 1
	if i > 0:
		return true
	else:
		return false

func is_close_to_a_wall() -> bool:
	return not close_to_left_wall() and not close_to_right_wall()



# This function checks if the first value is between the next two.
func interval(x: float, a: float, b: float) -> bool:
	if a < b:
		return a <= x and x <= b
	else:
		return b <= x and x <= a


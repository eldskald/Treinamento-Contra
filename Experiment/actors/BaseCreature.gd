extends KinematicBody2D
class_name BaseCreature

const MAX_SPEED = 3000.0



## PHYSICS SYSTEM ##

# Speed control value. Used to quickly speed up or slow down the game.
onready var control: float = 1

# Main variables. Their names are say it all. Store each body's true max speed, gravity and etc on an export on their
# own scene and initialize the variables here on the ready function as equal to the exports, so we can change the values
# of the variables here (the ones actually used for physics) without losing the initial value. For example, we can slow
# down creatures, invert gravity and other things on specific characters without losing the starting value, which is
# stored on the export on its scene.
var gravity: float
var acceleration: float
var max_natural_speed: float
var max_falling_speed: float
var max_rising_speed: float
# warning-ignore:unused_class_variable
var jump_force: float

# Some auxiliary variables, used to compute other things.
var move: float
var forced_velocity: float
var velocity := Vector2()


func _physics_process(delta):
	vertical_movement(delta)
	horizontal_movement(delta)
	
	# To prevent bugs, let's cap all speed to a set value equal to the constant MAX_SPEED.
	if velocity.length() > MAX_SPEED:
		velocity *= MAX_SPEED / velocity.length()
		
	velocity = move_and_slide(velocity*control, Vector2(0,-1))
	velocity /= control

func horizontal_movement(delta) -> void:
	if move != 0:
		move = move/abs(move)
	if velocity.x*move <= 0:
		velocity.x = 0
	velocity.x += acceleration*delta*move
	velocity.x = clamp(velocity.x, -max_natural_speed, max_natural_speed)
	velocity.x += forced_velocity

func vertical_movement(delta) -> void:
	velocity.y += gravity*delta
	velocity.y = clamp(velocity.y, -max_rising_speed, max_falling_speed)



## COMBAT ##
export(int) var hit_points
# warning-ignore:unused_class_variable
var shoot_distance_from_origin := Vector2()
# warning-ignore:unused_class_variable
export(PackedScene) var gun
onready var current_hp: int = hit_points

func is_dead() -> bool:
	return current_hp <= 0

# warning-ignore:unused_argument
# warning-ignore:unused_argument
func take_damage(damage_amount: int, source_direction = Vector2()) -> void:
	pass



## GET ADJACENT OBJECTS ##
func get_down_bodies():
	return get_node("Detectors/Down").get_overlapping_bodies()

func get_down_areas():
	return get_node("Detectors/Down").get_overlapping_areas()

func get_left_bodies():
	return get_node("Detectors/Left").get_overlapping_bodies()

func get_left_areas():
	return get_node("Detectors/Left").get_overlapping_areas()

func get_right_bodies():
	return get_node("Detectors/Right").get_overlapping_bodies()

func get_right_areas():
	return get_node("Detectors/Right").get_overlapping_areas()

func get_up_bodies():
	return get_node("Detectors/Up").get_overlapping_bodies()

func get_up_areas():
	return get_node("Detectors/Up").get_overlapping_areas()

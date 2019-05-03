extends KinematicBody2D
class_name BaseCreature

const MAX_SPEED = 3000



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
var jump_force: float

# Some auxiliary variables, used to compute other things.
var move := Vector2()
var natural_velocity := Vector2()
var forced_velocity := Vector2()
var remaining_velocity := Vector2()
var velocity := Vector2()
var natural_velocity_length: float

func _physics_process(delta):
	gravity_application(delta)
	move = move.normalized()
	accelerate(delta)
	velocity = natural_velocity + forced_velocity
	
	# To prevent bugs, let's cap all speed to a set value equal to the constant MAX_SPEED.
	if velocity.length() > MAX_SPEED:
		velocity *= MAX_SPEED / velocity.length()
		
	remaining_velocity = move_and_slide(velocity*control, Vector2(0,-1))
	remaining_velocity /= control

func accelerate(delta) -> void:
	natural_velocity_length += acceleration*delta
	clamp(natural_velocity_length, 0, max_natural_speed)
	natural_velocity = move*natural_velocity_length
	natural_velocity_length = natural_velocity.length()

func gravity_application(delta) -> void:
	forced_velocity.y += gravity*delta
	forced_velocity.y = clamp(forced_velocity.y, -max_falling_speed, MAX_SPEED)



## COMBAT ##
export(int) var max_health
export(int) var damage
export(float) var fire_rate
export(float) var shoot_distance_from_origin
export(PackedScene) var bullet
onready var health: int = max_health
onready var shoot_cooldown: float = 1.0/fire_rate

func is_dead() -> bool:
	return health <= 0

func take_damage(damage_amount: int, source_direction: Vector2) -> void:
	health -= damage_amount



## GET ADJACENT OBJECTS ##
func get_down_bodies():
	return $Detectors/Down.get_overlapping_bodies()

func get_down_areas():
	return $Detectors/Down.get_overlapping_areas()

func get_left_bodies():
	return $Detectors/Left.get_overlapping_bodies()

func get_left_areas():
	return $Detectors/Left.get_overlapping_areas()

func get_right_bodies():
	return $Detectors/Right.get_overlapping_bodies()

func get_right_areas():
	return $Detectors/Right.get_overlapping_areas()

func get_up_bodies():
	return $Detectors/Up.get_overlapping_bodies()

func get_up_areas():
	return $Detectors/Up.get_overlapping_areas()

extends KinematicBody2D
class_name BaseCreature

######COMBAT VARIABLES###########
export(int) var max_health
export(int) var damage
export(float) var shoot_cooldown
export(PackedScene) var bullet

########PHYSICS VARIABLES###########
export(float) var gravity
export(float) var acceleration
export(float) var absolute_max_speed
export(float) var max_falling_speed

var down_detector_list
var left_detector_list
var right_detector_list

onready var health: int = max_health
onready var direction := Vector2()

var natural_velocity := Vector2()
var forced_velocity := Vector2()
var remaining_velocity := Vector2()

func is_dead() -> bool:
	return health <= 0

func take_damage(damage_amount: int, source_direction: Vector2) -> void:
	health -= damage_amount
	

func get_direction_input(directional_input: Vector2) -> void:
	direction = directional_input.normalized()

func acccelerate(delta) -> void:
	natural_velocity = direction*delta*acceleration
	if natural_velocity.length() > absolute_max_speed:
		natural_velocity *= absolute_max_speed/natural_velocity.length()

func movement(delta):
	acccelerate(delta)
	remaining_velocity = move_and_slide(natural_velocity + forced_velocity)
	pass

func get_detectors():
	down_detector_list = $Detectors/Down.get_overlapping_bodies()
	right_detector_list = $Detectors/Right.get_overlapping_bodies()
	left_detector_list = $Detectors/Left.get_overlapping_bodies()
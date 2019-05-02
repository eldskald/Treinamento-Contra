extends KinematicBody2D
class_name BaseCreature

const MAX_SPEED = 3000

######COMBAT VARIABLES###########
export(int) var max_health
export(int) var damage
export(float) var fire_rate
export(float) var shoot_distance_from_origin
export(PackedScene) var bullet

########PHYSICS VARIABLES###########
export(float) var gravity
export(float) var acceleration
export(float) var absolute_max_speed
export(float) var max_falling_speed
export(float) var jump_force

var down_detector_list
var left_detector_list
var right_detector_list

onready var health: int = max_health
onready var direction := Vector2()
onready var shoot_cooldown: float = 1.0/fire_rate

var natural_velocity := Vector2()
var forced_velocity := Vector2()
var remaining_velocity := Vector2()
var velocity := Vector2()

func _physics_process(delta):
	gravity_application(delta)
	get_direction_input(direction)
	accelerate(delta)
	
	velocity = natural_velocity + forced_velocity
	if velocity.length() > MAX_SPEED:
		velocity *= MAX_SPEED / velocity.length()
	
	move_and_slide(velocity, Vector2(0,-1))

func is_dead() -> bool:
	return health <= 0

func take_damage(damage_amount: int, source_direction: Vector2) -> void:
	health -= damage_amount
	

func get_direction_input(directional_input: Vector2) -> void:
	direction = directional_input.normalized()

func accelerate(delta) -> void:
	natural_velocity = direction*delta*acceleration
	if natural_velocity.length() > absolute_max_speed:
		natural_velocity *= absolute_max_speed/natural_velocity.length()

func gravity_application(delta):
	forced_velocity.y += gravity*delta
	forced_velocity.y = clamp(forced_velocity.y, -max_falling_speed, MAX_SPEED)

func get_detectors():
	down_detector_list = $Detectors/Down.get_overlapping_bodies()
	right_detector_list = $Detectors/Right.get_overlapping_bodies()
	left_detector_list = $Detectors/Left.get_overlapping_bodies()
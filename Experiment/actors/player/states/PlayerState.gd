extends Node
class_name PlayerState

const MAX_SPEED = 3000.0
const BASE_STATE: int = 0
const WALL_CLINGING_STATE: int = 1
const LEDGE_HANGING_STATE: int = 2
const LEDGE_JUMPING_STATE: int = 3
const GLIDING_STATE: int = 4
const DIVING_STATE: int = 5
const DODGING_STATE: int = 6
const HEALING_STATE: int = 7

# warning-ignore:unused_class_variable
onready var player: Node = get_parent().get_parent()

# warning-ignore:unused_class_variable
var this_state: int



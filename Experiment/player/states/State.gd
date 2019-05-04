extends Node
class_name State

const BASE_STATE: int = 0
const WALL_CLINGING_STATE: int = 1
const LEDGE_HANGING_STATE: int = 2
const LEDGE_JUMPING_STATE: int = 3
const DIVING_STATE: int = 4
const DODGING_STATE: int = 5

onready var player: Node = get_parent().get_parent()

var this_state: int



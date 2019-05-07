extends Node

onready var locator = Locator.new(get_tree())
onready var player_actor = locator.find_entity("player")
onready var creature = get_parent()

var states = []

func pop_state() -> Node:
	return states.pop_front()

func push_state(state: Node) -> void:
	states.push_front(state)

func state(state_name: String) -> Node:
	return get_node_or_null(state_name)

func _ready():
	push_state(get_node("Waiting"))

func _process(delta: float):
	states[0].routine()
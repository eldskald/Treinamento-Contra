extends Node

onready var locator = Locator.new(get_tree())
onready var player_actor = locator.find_entity("player")
onready var creature = get_parent()

var states = []

func pop_state() -> Node:
	return states.pop_front()

func push_state(state: Node):
	states.push_front(state)
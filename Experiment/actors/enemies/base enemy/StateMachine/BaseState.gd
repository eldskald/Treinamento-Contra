extends Node
class_name BaseState

onready var creature_ai = get_parent()
onready var creature = creature_ai.get_parent()
onready var next_state: Node
onready var locator = get_parent().get_node("Finder")

func enter():
	pass

func exit():
	creature_ai.pop_state()
	creature_ai.push_state(next_state)
	next_state.enter()

func routine():
	pass

func is_attacking() -> bool:
	return creature.is_attacking

func player_in_range() -> bool:
	if !locator.has_entity("player"):
		return false
	var player_creature_distance = (locator.get("player").position - creature.position).length()
	return player_creature_distance <= creature.vision_range
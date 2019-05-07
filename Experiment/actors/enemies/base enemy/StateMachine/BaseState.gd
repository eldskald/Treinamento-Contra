extends Node
class_name BaseState

onready var creature_ai = get_parent()
onready var creature = creature_ai.creature
onready var player_actor = creature_ai.player_actor

func enter():
	pass

func exit():
	pass

func routine():
	pass
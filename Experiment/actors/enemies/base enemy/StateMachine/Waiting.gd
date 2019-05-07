extends BaseState

func exit():
	creature_ai.pop_state()

func routine():
	if (player_actor.position - creature.position).lenght() > creature.vision_range:
		pass
	
	else:
		exit()
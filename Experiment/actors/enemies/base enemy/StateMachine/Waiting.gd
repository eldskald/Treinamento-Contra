extends BaseState

func routine():
	if !player_in_range():
		pass
	
	else:
		next_state = creature_ai.state("AttackWindUp")
		print("inRange")
		exit()
extends BaseState

func enter():
	print("shooooooooot")

func routine():
	if !is_attacking():
		if player_in_range():
			next_state = get_parent().get_node("AttackWindUp")
		else:
			next_state = get_parent().get_node("Waiting")
		
		exit()

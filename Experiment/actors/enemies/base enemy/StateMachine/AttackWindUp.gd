extends BaseState

func routine():
	next_state = creature_ai.state("Attack")
	exit()


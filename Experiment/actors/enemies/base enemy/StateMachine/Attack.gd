extends BaseState


func enter():
	var direction = (self.locator.get("player").position - creature.position).normalized()
	creature.attack(direction)

func routine():
	if !is_attacking():
		if player_in_range():
			next_state = creature_ai.get_node("AttackWindUp")
		else:
			next_state = creature_ai.get_node("Waiting")
		
		exit()

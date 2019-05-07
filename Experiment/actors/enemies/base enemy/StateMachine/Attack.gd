extends BaseState


func enter():
	var direction = (self.locator.find_entity("player").position - creature.position).normalized()
	creature.attack(direction)

func routine():
	if !is_attacking():
		if player_in_range():
			next_state = get_parent().get_node("AttackWindUp")
		else:
			next_state = get_parent().get_node("Waiting")
		
		exit()

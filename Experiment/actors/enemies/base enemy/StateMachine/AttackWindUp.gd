extends BaseState

func enter():
	creature.is_attacking = true
	next_state = creature_ai.state("Attack")
	$Timer.start()

func _on_Timer_timeout():
	exit()

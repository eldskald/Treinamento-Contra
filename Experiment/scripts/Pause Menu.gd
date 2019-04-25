extends Control

func _physics_process(delta):
	
	# Unpausing.
	
	if Input.is_action_just_pressed("ui_start") or Input.is_action_just_pressed("ui_select") or Input.is_action_just_pressed("ui_cancel"):
			get_tree().set_pause(false)
			get_parent().gamePaused = false
			self.queue_free()

func _on_resume_pressed():
	get_tree().set_pause(false)
	get_parent().gamePaused = false
	self.queue_free()

func _on_quit_pressed():
	get_tree().quit()

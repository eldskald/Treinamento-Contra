extends KinematicBody2D

export(float) var gravityAccel

var velocity = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity.y += gravityAccel*delta
	velocity = move_and_slide(velocity)
#	pass

func kill():
	self.queue_free()

extends Area2D

export(float) var SPEED = 1000
export(float) var DAMAGE

var direction = Vector2()
var timer = 0

func _ready():
	get_node("VisibilityNotifier2D").connect("screen_exited", self, "_on_screen_exited")

func _physics_process(delta):
	position += SPEED*direction*delta
	timer += delta

func _on_Bullet_body_entered(body):
	if body.is_in_group("Enemy"):
		body._do_damage(DAMAGE)
		self.queue_free()
	elif body.is_in_group("block"):
		self.queue_free()

func _on_screen_exited():
	queue_free()
extends MarginContainer

var fullHeart = preload("res://prefabs/UI Elements/Full Heart.tscn")
var halfHeart = preload("res://prefabs/UI Elements/Half Heart.tscn")
var emptyHeart = preload("res://prefabs/UI Elements/Empty Heart.tscn")
var heart

func _on_update_hearts (hearts, currentHitPoints):
	for heart in $Hearts.get_children():
		heart.queue_free()
	for i in range(hearts):
		if currentHitPoints <= 2*i:
			heart = emptyHeart.instance()
		elif currentHitPoints == 2*i + 1:
			heart = halfHeart.instance()
		elif currentHitPoints >= 2*(i+1):
			heart = fullHeart.instance()
		$Hearts.add_child(heart)

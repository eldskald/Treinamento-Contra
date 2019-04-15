extends Control

var fullHeart = preload("res://prefabs/UI Elements/Full Heart.tscn")
var halfHeart = preload("res://prefabs/UI Elements/Half Heart.tscn")
var emptyHeart = preload("res://prefabs/UI Elements/Empty Heart.tscn")
var filledPack = preload("res://prefabs/UI Elements/Filled Pack.tscn")
var usedPack = preload("res://prefabs/UI Elements/Used Pack.tscn")
var heart
var pack

func _on_update_hearts (hearts, currentHitPoints, maxPacks, currentPacks):
	for x in $Hearts.get_children():
		x.queue_free()
	for i in range(hearts):
		if currentHitPoints <= 2*i:
			heart = emptyHeart.instance()
		elif currentHitPoints == 2*i + 1:
			heart = halfHeart.instance()
		elif currentHitPoints >= 2*(i+1):
			heart = fullHeart.instance()
		$Hearts.add_child(heart)
		
	for x in $"Health Packs".get_children():
		x.queue_free()
	for i in range(maxPacks):
		if currentPacks > i:
			pack = filledPack.instance()
		elif currentPacks <= i:
			pack = usedPack.instance()
		$"Health Packs".add_child(pack)
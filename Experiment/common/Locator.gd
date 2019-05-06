extends Object
class_name Locator



var tree: SceneTree

func _init(tree: SceneTree):
	self.tree = tree

func has_entity(entity_name: String):
	return len(self.tree.get_nodes_in_group(entity_name)) != 0

func find_entity(entity_name: String):
	if not has_entity(entity_name):
		return null
	
	var entity_list: Array = self.tree.get_nodes_in_group(entity_name)
	return entity_list[0]


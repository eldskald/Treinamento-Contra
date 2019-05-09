extends Node
class_name Finder



func has_entity(entity_name: String):
	return len(get_tree().get_nodes_in_group(entity_name)) != 0

func get(entity_name: String):
	if not has_entity(entity_name):
		return null
	
	var entity_list: Array = self.get_tree().get_nodes_in_group(entity_name)
	return entity_list[0]


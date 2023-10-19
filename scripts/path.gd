class_name MobPath
extends Path2D


var offset_to_start : float = 96.0


func calculate_path(start_node = null):
	if start_node and start_node is Vector2:
		offset_to_start = get_curve().get_closest_offset(start_node)


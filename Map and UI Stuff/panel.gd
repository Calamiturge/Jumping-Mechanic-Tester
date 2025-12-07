extends Panel

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		var focus = get_viewport().gui_get_focus_owner()
		if is_instance_valid(focus):
			focus.release_focus()

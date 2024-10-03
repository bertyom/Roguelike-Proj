extends ScrollContainer

func _ready() -> void:
	var h_scroll = get_h_scroll_bar()
	var v_scroll = get_v_scroll_bar()
	
	if h_scroll:
		h_scroll.add_to_group("item_drag&drop")
	if v_scroll:
		v_scroll.add_to_group("item_drag&drop")

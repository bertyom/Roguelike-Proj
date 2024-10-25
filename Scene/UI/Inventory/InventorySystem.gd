extends Control

var template_inv_slot = preload("res://Scene/UI/Inventory/InventorySlot.tscn")
@onready var gridcontainer = get_node("Inventory/ScrollContainer/MainInventory")
var need_to_add = false

var dragging = false
var drag_start_position = Vector2.ZERO

# Window dragging variables
var window_dragging = false
var window_drag_start_position = Vector2.ZERO

func _ready():
	CommonFunctions.inventory_node = self
	for i in PlayerData.inv_data.keys():
		var inv_slot_new = template_inv_slot.instantiate()
		if PlayerData.inv_data[i]["Item"] != null:
			var item_name = DatabaseManager.item_cache[str(PlayerData.inv_data[i]["Item"])]["Name"]
			var icon_texture = load("res://Image/UI/Inventory/Icons/"+item_name+".png")
			inv_slot_new.get_node("Icon").set_texture(icon_texture)
			var item_stack = PlayerData.inv_data[i]["StackSize"]
			if item_stack != null and item_stack > 1:
				if item_stack > 999:
					inv_slot_new.get_node("Stack").set_text(str(int(item_stack/1000)) + "K")
				else: inv_slot_new.get_node("Stack").set_text(str(item_stack))
		gridcontainer.add_child(inv_slot_new, true)
	
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("UI_INV_SHOW"):
		self.visible = !self.visible
		
	if not visible:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if _is_draggable_area(event.global_position):
					window_dragging = true
					window_drag_start_position = get_global_mouse_position() - global_position
			else:
				# Stop dragging
				dragging = false
				window_dragging = false
	
	if event is InputEventMouseMotion:
		if window_dragging:
			# Move the window
			global_position = get_global_mouse_position() - window_drag_start_position

		#Limit the inventory position to stay within the viewport
		var viewport_rect = get_viewport_rect()
		global_position.x = clamp(global_position.x, 0, viewport_rect.size.x - size.x)
		global_position.y = clamp(global_position.y, 0, viewport_rect.size.y - size.y)

func _is_draggable_area(point: Vector2) -> bool:
	if not get_global_rect().has_point(point):
		return false
	var draggable_items = get_tree().get_nodes_in_group("item_drag&drop")
	for item in draggable_items:
		if item is Control and item.get_global_rect().has_point(point):
			return false
	return true

extends TextureRect

@onready var parent = self.get_parent()
@onready var tooltip = preload("res://Scene/UI/Inventory/ToolTip.tscn")
var origin_data_dict
var target_data_dict
var container_data

func _ready():
	draw.connect(parent._on_Icon_draw)

func _get_drag_data(_pos):
	# Retrieve information about the slot we are dragging
	var equipslot = get_parent().get_name()
	origin_data_dict = PlayerData.equipment_data
	var data = {}
	data["origin_node"] = self
	data["origin_item_id"] = origin_data_dict[equipslot]
	data["origin_panel"] = "Equipment"
	data["origin_equipslot"] = equipslot
	data["origin_texture"] = texture
	data["origin_stackable"] = false
	
	var drag_texture = TextureRect.new()
	drag_texture.expand = true
	drag_texture.texture = texture
	drag_texture.size = Vector2(25, 25)
	
	var control = Control.new()
	control.add_child(drag_texture)
	drag_texture.position = -0.5 * drag_texture.size 
	set_drag_preview(control)
	
	return data

func _can_drop_data(_pos, data):
	if ContainerLoot.current_container_ID != null:
		container_data = ContainerLoot.container_loot[ContainerLoot.current_container_ID]
	# Check if we can drop an item in this slot
	var target_equipslot = get_parent().get_name()
	if target_equipslot == data["origin_equipslot"]:
		if PlayerData.equipment_data[target_equipslot] == null:
			data["target_item_id"] = null
			data["target_texture"] = null
		else:
			data["target_item_id"] = PlayerData.equipment_data[target_equipslot]
			data["target_texture"] = texture
		return true
	else:
		return false

func _drop_data(_pos, data):
	if ContainerLoot.current_container_ID != null:
		container_data = ContainerLoot.container_loot[ContainerLoot.current_container_ID]
	# What happens when we drop an item in this slot
	var target_equipslot = get_parent().get_name( )
	var origin_slot = data["origin_node"].get_parent( ).get_name( )

	# Identify the origin slot type and get its data
	if origin_slot.begins_with("Inv"):
		origin_data_dict = PlayerData.inv_data
	elif origin_slot.begins_with("Cnt"):
		origin_data_dict = container_data
	else:
		origin_data_dict = PlayerData.equipment_data
	
	# Update the data of the origin
	if data["origin_panel"] != "Equipment":
		origin_data_dict[origin_slot]["Item"] = data["target_item_id"]
	else: #Equipment
		origin_data_dict[origin_slot] = data["target_item_id"]

	# Update the texture of the origin
	if data["origin_panel"] == "Equipment" and data["target_item_id"] == null:
		var default_texture = null
		data["origin_node"].texture = default_texture
	else:
		data["origin_node"].texture = data["target_texture"]

	# Update the texture and data of the target
	PlayerData.equipment_data[target_equipslot] = data["origin_item_id"]
	texture = data["origin_texture"]

func _make_custom_tooltip(for_text):
	var tooltip = preload("res://Scene/UI/Inventory/ToolTip.tscn").instantiate()
	tooltip.origin = "Equipment"
	tooltip.slot = get_parent().get_name()
	return tooltip

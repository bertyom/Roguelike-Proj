extends TextureRect

@onready var tooltip = preload("res://Scene/UI/Inventory/ToolTip.tscn")
@onready var split_popup = preload("res://Scene/UI/Inventory/SplitStackPopUp.tscn")
@onready var container_data = ContainerLoot.container_loot[ContainerLoot.current_container_ID]
var origin_data_dict
var target_data_dict
var drag_texture

func _gui_input(event):
#Quick transfer with ctrl+click
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and Input.is_action_pressed("UI_INV_QSTACK"):
			var cnt_slot = get_parent().get_name() 
			CommonFunctions._transfer_from_cnt(cnt_slot)
			if has_node("Tooltip") == true:
				get_node("Tooltip").free()

func _get_drag_data(_pos):
# Retrieve information about the slot we are dragging
	var inv_slot = get_parent().get_name()
	origin_data_dict = container_data
	if origin_data_dict[inv_slot]["Item"] != null:
		var data = {}
		data["origin_node"] = self
		data["origin_item_name"] = GameData.item_data[str(origin_data_dict[inv_slot]["Item"])]["Name"]
		data["origin_item_id"] = origin_data_dict[inv_slot]["Item"]
		data["origin_panel"] = "Container"
		data["origin_equipslot"] = GameData.item_data[str(origin_data_dict[inv_slot]["Item"])]["EquipSlot"]
		data["origin_stackable"] = GameData.item_data[str(origin_data_dict[inv_slot]["Item"])]["IsStackable"]
		data["origin_stack"] = origin_data_dict[inv_slot]["StackSize"]
		data["origin_stack_limit"] = GameData.item_data[str(origin_data_dict[inv_slot]["Item"])]["MaxStack"]
		data["origin_texture"] = texture
	
		drag_texture = TextureRect.new()
		drag_texture.expand = true
		drag_texture.texture = texture
		drag_texture.size = Vector2(25, 25)
		
		var control = Control.new()
		control.add_child(drag_texture)
		drag_texture.position = -0.5 * drag_texture.size 
		set_drag_preview(control)
	
		return data

func _can_drop_data(_pos, data):
	# Check if we can drop an item in this slot
	var target_slot = get_parent().get_name()
	if target_slot.begins_with("Inv"):
		target_data_dict = PlayerData.inv_data
	elif target_slot.begins_with("Cnt"):
		target_data_dict = container_data
	else:
		target_data_dict = PlayerData.equipment_data
	
	if target_data_dict[target_slot] != null and target_data_dict[target_slot]["Item"] == null: # We move an item
		data["target_item_id"] = null
		data["target_texture"] = null
		data["target_stack"] = null
		return true
	else: # We swap an item
		if Input.is_action_pressed("UI_INV_SPLIT"):
			return false
		else:
			data["target_item_id"] = target_data_dict[target_slot]["Item"]
			data["target_texture"] = texture
			data["target_stack"] = target_data_dict[target_slot]["StackSize"]
			if data["origin_panel"] == "Equipment":
				var target_equipslot = GameData.item_data[str(target_data_dict[target_slot]["Item"])]["EquipSlot"]
				if target_equipslot == data["origin_equipslot"]:
					return true
				else:
					return false
			else: # data["origin_panel"] == "Inventory" or "Container":
				return true


func _drop_data(_pos, data):
	if is_instance_valid(data["origin_node"]):
		# What happens when we drop an item in this slot
		var target_slot = get_parent().get_name()
		var origin_slot = data["origin_node"].get_parent().get_name()

		# Identify the target slot type and get its data
		if target_slot.begins_with("Inv"):
			target_data_dict = PlayerData.inv_data
		elif target_slot.begins_with("Cnt"):
			target_data_dict = container_data
		else:
			target_data_dict = PlayerData.equipment_data

		# Identify the origin slot type and get its data
		if origin_slot.begins_with("Inv"):
			origin_data_dict = PlayerData.inv_data
		elif origin_slot.begins_with("Cnt"):
			origin_data_dict = container_data
		else:
			origin_data_dict = PlayerData.equipment_data

		if data["origin_node"] == self:
			pass
		
		elif Input.is_action_pressed("UI_INV_SPLIT") and data["origin_stackable"] == true:
			if data["origin_stack"] > 2:
		#show split popup
				var split_popup_instance = split_popup.instantiate()
				split_popup_instance.position = get_parent().get_global_transform_with_canvas().origin + Vector2(0,20)
				split_popup_instance.data = data
				add_child(split_popup_instance)
			if data["origin_stack"] == 2:
				_SplitStack(1, data)
		else:
			# Update the data of the origin
			if data["target_item_id"] == data["origin_item_id"] and data["origin_stackable"] == true:
				origin_data_dict[origin_slot]["Item"] = null
				origin_data_dict[origin_slot]["StackSize"] = null
			elif data["origin_panel"] != "Equipment":
				origin_data_dict[origin_slot]["Item"] = data["target_item_id"]
				origin_data_dict[origin_slot]["StackSize"] = data["target_stack"]
			else: #Equipment
				PlayerData.equipment_data[origin_slot] = data["target_item_id"]

			# Update the texture of the origin
			if data["target_item_id"] == data["origin_item_id"] and data["origin_stackable"] == true:
				data["origin_node"].texture = null
				data["origin_node"].get_node("../Stack").set_text("")
			
			elif data["origin_panel"] == "Equipment" and data["target_item_id"] == null:
				var default_texture = null
				data["origin_node"].texture = default_texture
			else:
				data["origin_node"].texture = data["target_texture"]
				if data["target_stack"] != null and data["target_stack"] > 1 and data["target_stack"] < 999:
					data["origin_node"].get_node("../Stack").set_text(str(data["target_stack"]))
				elif data["target_stack"] != null and data["target_stack"] > 999:
					data["origin_node"].get_node("../Stack").set_text(str(int(data["target_stack"]/1000))+"K")
				elif data["origin_panel"] != "Equipment":
					data["origin_node"].get_node("../Stack").set_text("")

			# Update the texture, label, and data of the target
			if data["target_item_id"] == data["origin_item_id"] and data["origin_stackable"] == true:
				var new_stack = data["target_stack"] + data["origin_stack"]
				if new_stack > data['origin_stack_limit']:
					var split = new_stack - data['origin_stack_limit']
					new_stack = new_stack - split
					data['origin_node'].texture = texture
					origin_data_dict[origin_slot]["Item"] = data["origin_item_id"]
					origin_data_dict[origin_slot]["StackSize"] = split
					if split > 999:
						data['origin_node'].get_node('../Stack').set_text(str(int(split/1000))+"K")
					elif split > 1:
						data['origin_node'].get_node('../Stack').set_text(str(split))
				target_data_dict[target_slot]["StackSize"] = new_stack
				if new_stack > 999:
					get_node("../Stack").set_text(str(int(new_stack/1000))+"K")
				else:
					get_node("../Stack").set_text(str(new_stack))
					
			else:
				target_data_dict[target_slot]["Item"] = data["origin_item_id"]
				texture = data["origin_texture"]
				if data["origin_panel"] != "Equipment":
					target_data_dict[target_slot]["StackSize"] = data["origin_stack"]
					if data["origin_stack"] != null and data["origin_stack"] > 1 and data["origin_stack"] < 999:
						get_node("../Stack").set_text(str(data["origin_stack"]))
					elif data["origin_stack"] != null and data["origin_stack"] > 999:
						get_node("../Stack").set_text(str(int(data["origin_stack"]/1000))+"K")
					else:
						get_node("../Stack").set_text("")

func _SplitStack(split_amount, data):
	if is_instance_valid(data["origin_node"]):
		# What happens when we drop an item in this slot
		var target_slot = get_parent().get_name( )
		var origin_slot = data["origin_node"].get_parent( ).get_name( )
		
		# Identify the target slot type and get its data
		if target_slot.begins_with("Inv"):
			target_data_dict = PlayerData.inv_data
		elif target_slot.begins_with("Cnt"):
			target_data_dict = container_data
		else:
			target_data_dict = PlayerData.equipment_data

		# Identify the origin slot type and get its data
		if origin_slot.begins_with("Inv"):
			origin_data_dict = PlayerData.inv_data
		elif origin_slot.begins_with("Cnt"):
			origin_data_dict = container_data
		else:
			origin_data_dict = PlayerData.equipment_data
		if data["origin_node"] == self:
			pass
		
		#Update origin and target stacks
		origin_data_dict[origin_slot]["StackSize"] = data["origin_stack"] - split_amount
		target_data_dict[target_slot]["Item"] = data["origin_item_id"]
		target_data_dict[target_slot]["StackSize"] = split_amount
		texture = data["origin_texture"]
		
		#Update orign stack numbers
		if data["origin_stack"] - split_amount > 1 and data["origin_stack"] - split_amount < 999:
			data["origin_node"].get_node("../Stack").set_text(str(data["origin_stack"] - split_amount))
		elif data["origin_stack"] - split_amount > 1 and data["origin_stack"] - split_amount > 999:
			data["origin_node"].get_node("../Stack").set_text(str(int((data["origin_stack"]-split_amount)/1000))+"K")
		else:
			data["origin_node"].get_node("../Stack").set_text("")
		
		#Update target stack numbers
		if split_amount > 1 and split_amount < 999:
			get_node("../Stack").set_text(str(split_amount))
		elif split_amount > 1 and split_amount > 999:
			get_node("../Stack").set_text(str(int(split_amount/1000))+"K")
		else:
			get_node("../Stack").set_text("")

func _make_custom_tooltip(for_text):
	var tooltip = preload("res://Scene/UI/Inventory/ToolTip.tscn").instantiate()
	tooltip.origin = "Inventory"
	tooltip.slot = get_parent().get_name()
	return tooltip

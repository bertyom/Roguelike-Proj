extends Node

var inventory_node
var container_node
var UI_node
var item_already_added = false
var item_already_deleted = false
var slot_name
var slot_data
var max_stack
var gridcontainer
var container_data
signal player_stat_changed(stat_name, stat_value)
signal player_exp_changed(exp_name, exp_value)
@export var navigation_node: NodePath


func update_health(amount):
	PlayerData.player_base_stats["health"] += amount
	emit_signal("player_stat_changed", "health", PlayerData.player_base_stats["health"], PlayerData.player_base_stats["max_health"])

func update_max_health(amount):
	PlayerData.player_base_stats["max_health"] += amount
	emit_signal("player_stat_changed", "max_health", PlayerData.player_base_stats["health"], PlayerData.player_base_stats["max_health"])

func update_glint(amount):
	PlayerData.player_base_stats["glint"] += amount
	emit_signal("player_stat_changed", "glint", PlayerData.player_base_stats["glint"], PlayerData.player_base_stats["max_glint"])

func update_max_glint(amount):
	PlayerData.player_base_stats["max_glint"] += amount
	emit_signal("player_stat_changed", "glint", PlayerData.player_base_stats["glint"], PlayerData.player_base_stats["max_glint"])

func update_stamina(amount):
	PlayerData.player_base_stats["stamina"] += amount
	emit_signal("player_stat_changed", "stamina", PlayerData.player_base_stats["stamina"], PlayerData.player_base_stats["max_stamina"])

func update_max_stamina(amount):
	PlayerData.player_base_stats["max_stamina"] += amount
	emit_signal("player_stat_changed", "stamina", PlayerData.player_base_stats["stamina"], PlayerData.player_base_stats["max_stamina"])

func update_exp(amount):
	PlayerData.player_exp["exp"] += amount
	emit_signal("player_exp_changed", "exp", PlayerData.player_exp["exp"])

func update_next_lvl_exp(amount):
	PlayerData.player_exp["next_lvl_exp"] += amount
	emit_signal("player_exp_changed", "next_lvl_exp", PlayerData.player_exp["next_lvl_exp"])

func _update_inventory_UI():
	gridcontainer = inventory_node.gridcontainer
	for i in PlayerData.inv_data.keys():
		var inv_slot = gridcontainer.get_node(str(i))
		if PlayerData.inv_data[i]["Item"] != null:
			var item_name = GameData.item_data[str(PlayerData.inv_data[i]["Item"])]["Name"]
			var icon_texture = load("res://Image/UI/Inventory/Icons/"+item_name+".png")
			inv_slot.get_node("Icon").set_texture(icon_texture)
			var item_stack = PlayerData.inv_data[i]["StackSize"]
			if item_stack != null and item_stack > 1:
				if item_stack > 999:
					inv_slot.get_node("Stack").set_text(str(int(item_stack/1000)) + "K")
				else: inv_slot.get_node("Stack").set_text(str(item_stack))
		else:
			inv_slot.get_node("Icon").set_texture(null)
			inv_slot.get_node("Stack").set_text("")


func _update_container_UI():
	if ContainerLoot.current_container_ID != null:
		container_data = ContainerLoot.container_loot[ContainerLoot.current_container_ID]
	gridcontainer = container_node.gridcontainer
	for i in container_data.keys():
		var inv_slot = gridcontainer.get_node(str(i))
		if container_data[i]["Item"] != null:
			var item_name = GameData.item_data[str(container_data[i]["Item"])]["Name"]
			var icon_texture = load("res://Image/UI/Inventory/Icons/"+item_name+".png")
			inv_slot.get_node("Icon").set_texture(icon_texture)
			var item_stack = container_data[i]["StackSize"]
			if item_stack != null and item_stack > 1:
				if item_stack > 999:
					inv_slot.get_node("Stack").set_text(str(int(item_stack/1000)) + "K")
				else: inv_slot.get_node("Stack").set_text(str(item_stack))
		else:
			inv_slot.get_node("Icon").set_texture(null)
			inv_slot.get_node("Stack").set_text("")

func _add_item(item_ID,quantity):
	max_stack = GameData.item_data[str(item_ID)]["MaxStack"]
	for i in range(1, 80):
		slot_name = "InvSlot" +str(i)
		slot_data = PlayerData.inv_data.get(slot_name)
		if slot_data["Item"] == null:
			PlayerData.inv_data[slot_name] = {"Item": item_ID, "StackSize": quantity}
			item_already_added = true
			_update_inventory_UI()
			break
		elif str(slot_data["Item"]) == str(item_ID) and slot_data["StackSize"]+quantity <= max_stack:
			slot_data["StackSize"] = slot_data["StackSize"] + quantity
			item_already_added = true
			_update_inventory_UI()
			break
	if item_already_added != true:
		print("No inventory space")

#might be broken, needs testing
func _remove_item(item_ID, quantity):
	for i in range(1, 80):
		slot_name = "InvSlot" + str(i)
		slot_data = PlayerData.inv_data.get(slot_name)
		if str(slot_data["Item"]) == str(item_ID):
			if slot_data["StackSize"] > quantity:
				slot_data["StackSize"] -= quantity
				item_already_deleted = true
				_update_inventory_UI()
				break
			elif slot_data["StackSize"] == quantity:
				PlayerData.inv_data[slot_name] = {"Item": null, "StackSize": null}
				item_already_deleted = true
				_update_inventory_UI()
				break
	if item_already_deleted != true:
		print("No item found")

func _transfer_from_inv(slot_name):
	if PlayerData.inv_data[slot_name]["Item"] != null:
		var cnt_slot_name
		var cnt_slot_data
		var item_to_transfer = PlayerData.inv_data[slot_name]["Item"]
		var stack_to_transfer = PlayerData.inv_data[slot_name]["StackSize"]
		var max_stack = GameData.item_data[str(item_to_transfer)]["MaxStack"]
		var is_stackable = GameData.item_data[str(item_to_transfer)]["IsStackable"]
		if ContainerLoot.current_container_ID != null:
			container_data = ContainerLoot.container_loot[ContainerLoot.current_container_ID]
		for i in container_data:
			cnt_slot_data = container_data[i]
			# If the slot is empty, move the items to the slot and break the loop
			if cnt_slot_data["Item"] == null:
				cnt_slot_data["Item"] = item_to_transfer
				if is_stackable:
					cnt_slot_data["StackSize"] = min(stack_to_transfer, max_stack)
					stack_to_transfer -= min(stack_to_transfer, max_stack)
				else:
					PlayerData.inv_data[slot_name]["Item"] = null
					PlayerData.inv_data[slot_name]["StackSize"] = null
					break
			# If the slot has the same item and has room in the stack, add the items
			elif is_stackable and cnt_slot_data["Item"] == item_to_transfer and cnt_slot_data["StackSize"] < max_stack:
				var transfer = min(stack_to_transfer, max_stack - cnt_slot_data["StackSize"])
				cnt_slot_data["StackSize"] += transfer
				stack_to_transfer -= transfer
			# Continue if there's no more items to transfer
			if stack_to_transfer == 0:
				break
		# Check if there are items left over after the loop and remove them from the original slot
		if stack_to_transfer == 0:
			PlayerData.inv_data[slot_name]["Item"] = null
			PlayerData.inv_data[slot_name]["StackSize"] = null
		else:
			PlayerData.inv_data[slot_name]["StackSize"] = stack_to_transfer
		_update_inventory_UI()
		_update_container_UI()

func _transfer_from_cnt(slot_name):
	if ContainerLoot.container_loot[ContainerLoot.current_container_ID][slot_name]["Item"] != null:
		var inv_slot_name
		var inv_slot_data
		var item_to_transfer = ContainerLoot.container_loot[ContainerLoot.current_container_ID][slot_name]["Item"]
		var stack_to_transfer = ContainerLoot.container_loot[ContainerLoot.current_container_ID][slot_name]["StackSize"]
		var max_stack = GameData.item_data[str(item_to_transfer)]["MaxStack"]
		var is_stackable = GameData.item_data[str(item_to_transfer)]["IsStackable"]
		for i in PlayerData.inv_data:
			inv_slot_data = PlayerData.inv_data[i]
			# If the slot is empty, move the items to the slot and break the loop
			if inv_slot_data["Item"] == null:
				inv_slot_data["Item"] = item_to_transfer
				if is_stackable:
					inv_slot_data["StackSize"] = min(stack_to_transfer, max_stack)
					stack_to_transfer -= min(stack_to_transfer, max_stack)
				else:
					ContainerLoot.container_loot[ContainerLoot.current_container_ID][slot_name]["Item"] = null
					ContainerLoot.container_loot[ContainerLoot.current_container_ID][slot_name]["StackSize"] = null
					break
			# If the slot has the same item and has room in the stack, add the items
			elif is_stackable and inv_slot_data["Item"] == item_to_transfer and inv_slot_data["StackSize"] < max_stack:
				var transfer = min(stack_to_transfer, max_stack - inv_slot_data["StackSize"])
				inv_slot_data["StackSize"] += transfer
				stack_to_transfer -= transfer
			# Continue if there's no more items to transfer
			if stack_to_transfer == 0:
				break
		# Check if there are items left over after the loop and remove them from the original slot
		if stack_to_transfer == 0:
			ContainerLoot.container_loot[ContainerLoot.current_container_ID][slot_name]["Item"] = null
			ContainerLoot.container_loot[ContainerLoot.current_container_ID][slot_name]["StackSize"] = null
		else:
			ContainerLoot.container_loot[ContainerLoot.current_container_ID][slot_name]["StackSize"] = stack_to_transfer
		_update_inventory_UI()
		_update_container_UI()

func parse_json(file_path: String):
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file != null:
		var result = JSON.parse_string(file.get_as_text())
		file.close()
		if typeof(result) == TYPE_DICTIONARY:
			return result
		else:
			print("Failed to parse JSON file: ", file_path)
			return {}
	else:
		print("Failed to open file: ", file_path)
		return {}

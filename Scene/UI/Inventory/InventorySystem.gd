extends Control

var template_inv_slot = preload("res://Scene/UI/Inventory/InventorySlot.tscn")
@onready var gridcontainer = get_node("Inventory/ScrollContainer/MainInventory")
@onready var inventory_instance = $"."
var need_to_add = false

func _ready():
	CommonFunctions.inventory_node = inventory_instance
	for i in PlayerData.inv_data.keys():
		var inv_slot_new = template_inv_slot.instantiate()
		if PlayerData.inv_data[i]["Item"] != null:
			var item_name = GameData.item_data[str(PlayerData.inv_data[i]["Item"])]["Name"]
			var icon_texture = load("res://Images/Inventory/"+item_name+".png")
			inv_slot_new.get_node("Icon").set_texture(icon_texture)
			var item_stack = PlayerData.inv_data[i]["StackSize"]
			if item_stack != null and item_stack > 1:
				if item_stack > 999:
					inv_slot_new.get_node("Stack").set_text(str(int(item_stack/1000)) + "K")
				else: inv_slot_new.get_node("Stack").set_text(str(item_stack))
		gridcontainer.add_child(inv_slot_new, true)

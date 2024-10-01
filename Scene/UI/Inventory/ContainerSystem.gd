extends Control

var template_cnt_slot = preload("res://Scene/UI/Inventory/ContainerSlot.tscn")
@onready var gridcontainer = $BG/ScrollContainer/GridContainer


func _ready():
	CommonFunctions.container_node = $"."
	var container_data = ContainerLoot.container_loot[ContainerLoot.current_container_ID]
	for i in container_data.keys():
		var cnt_slot_new = template_cnt_slot.instantiate()
		if container_data[i]["Item"] != null:
			var item_name = GameData.item_data[str(container_data[i]["Item"])]["Name"]
			var icon_texture = load("res://Images/Inventory/"+item_name+".png")
			cnt_slot_new.get_node("Icon").set_texture(icon_texture)
			var item_stack = container_data[i]["StackSize"]
			if item_stack != null and item_stack > 1:
				if item_stack > 999:
					cnt_slot_new.get_node("Stack").set_text(str(int(item_stack/1000)) + "K")
				else: cnt_slot_new.get_node("Stack").set_text(str(item_stack))
		gridcontainer.add_child(cnt_slot_new, true)

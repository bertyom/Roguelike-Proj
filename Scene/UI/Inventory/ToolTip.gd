extends Popup

var origin = ""
var slot = ""
var valid = false
var stacksize
var container_data = {}

func _ready():
	if ContainerLoot.current_container_ID != null:
		container_data = ContainerLoot.container_loot[ContainerLoot.current_container_ID]
	var item_id
	if origin == "Inventory":
		if PlayerData.inv_data[slot]["Item"] != null:
			item_id = str(PlayerData.inv_data[slot]["Item"])
			stacksize = PlayerData.inv_data[slot]["StackSize"]
			if stacksize == null:
				stacksize = 1
			valid = true
	elif origin == "Container":
		if container_data[slot]["Item"] != null:
			item_id = str(container_data[slot]["Item"])
			stacksize = container_data[slot]["StackSize"]
			if stacksize == null:
				stacksize = 1
			valid = true
	else:
		if PlayerData.equipment_data[slot] != null:
			item_id = str(PlayerData.equipment_data[slot])
			stacksize = 1
			valid = true
			
	if valid == true:
		if stacksize > 1:
			get_node("Texture/MarginContainer/V1/ItemName").set_text(GameData.item_data[item_id]["Name"]+" x"+str(stacksize))
		else: 
			get_node("Texture/MarginContainer/V1/ItemName").set_text(GameData.item_data[item_id]["Name"])
		var item_stat = 1
		for i in range(GameData.item_stats.size()):
			var stat_name = GameData.item_stats[i]
			var stat_label = GameData.item_stats_labels[i]
			if GameData.item_data[item_id][stat_name] != null:
				var stat_value = GameData.item_data[item_id][stat_name]
				get_node("Texture/MarginContainer/V1/V2/Stat" + str(item_stat) + "/Label").set_text(stat_label + ": " +str(stat_value))
				item_stat += 1
		#if $TextureRect/MarginContainer/VBoxContainer/Stat1/Label.text == "":
			#$TextureRect.texture = load("res://Images/Inventory/ToolTipSmall.png")

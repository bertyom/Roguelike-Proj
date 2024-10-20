extends Node

var item_data = {}
var item_stats = ["Attack", "Knockback", "Defense", "HealthRestored", "EnergyRestored", "ManaRestored"]
var item_stats_labels = ["Attack", "Knockback", "Defense", "Health Restored", "Energy Restored", "mana Restored"]
var equip_slot = {}
var weapon_lookup_data = {}
var enemy_weapon_stats = {}

func _ready():
	item_data = CommonFunctions.parse_json("res://Data/Item Database.json")

	for item_id in item_data:
		var item_info = item_data[item_id]
		var item_name = item_info["Name"]
		if item_info.has("Attack") and item_info["Attack"] != null:
			weapon_lookup_data[item_name] = item_id

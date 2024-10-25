extends Node

var item_data = {}
var item_stats = ["Attack", "Knockback", "Defense", "HealthRestored", "EnergyRestored", "ManaRestored"]
var item_stats_labels = ["Attack", "Knockback", "Defense", "Health Restored", "Energy Restored", "Mana Restored"]
var equip_slot = {}
var enemy_weapon_stats = {}

func _ready():
	item_data = DatabaseManager.item_cache

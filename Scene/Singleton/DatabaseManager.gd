extends Node

var db: SQLite = null
var db_name := "res://Data/Items.db"

# Caches for frequently accessed data
var item_cache := {}
var weapon_cache := {}
var equipment_cache := {}

func _ready():
	_initialize_database()
	_load_caches()

func _initialize_database():
	db = SQLite.new()
	db.path = db_name
	db.verbosity_level = SQLite.VERBOSE
	# Since this is a read-only database, we can enable read_only mode
	db.read_only = true
	
	var success = db.open_db()
	if not success:
		push_error("Failed to open database at " + db_name)
		return

# Load all data into memory at startup since it's static
func _load_caches():
	# Cache all items
	var all_items = db.select_rows("ItemDatabase", "", ["*"])
	for item in all_items:
		item_cache[item.ItemId] = item
		
	for cached_item in item_cache.values():
		if cached_item["Attack"] != null:
			weapon_cache[cached_item.ItemId] = cached_item
			
		if cached_item["EquipSlot"] != null:
			equipment_cache[cached_item.ItemId] = cached_item

func get_item(item_id: String) -> Dictionary:
	return item_cache.get(item_id, {})

func get_items(ids: Array) -> Array:
	var items := []
	for id in ids:
		var item = item_cache.get(id, {})
		if not item.is_empty():
			items.append(item)
	return items

func get_items_by_type(type: String) -> Array:
	var matching_items := []
	for item in item_cache:
		if item["Type"] == type:
			matching_items.append(item)
	return matching_items

func get_stack_info(item_id: String) -> Dictionary:
	var item = item_cache["Item"]
	return {
		"is_stackable": item["IsStackable"],
		"max_stack": item["MaxStack"]
	}

func get_weapon_id_by_name(weapon_name: String) -> String:
	for weapon in weapon_cache.values():
		if weapon["Name"] == weapon_name:
			return weapon.ItemId
	return ""

func _exit_tree():
	if db:
		db.close_db()

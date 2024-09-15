extends CharacterBody2D
class_name Entity

@export var HP: int: set = set_hp
@export var Max_HP: int
@export var DMG: String: set = set_dmg
@export var armor: int
var health_bar: ProgressBar

func _ready() -> void:
	health_bar = get_node_or_null("HealthBar")
	if health_bar:
		health_bar.max_value = Max_HP
		health_bar.value = HP

func take_damage(amount):
	set_hp(HP-amount)
	if HP <= 0:
		die()

func die():
	var current_pos: Vector2i = GameMap.current_traverse_node.local_to_map(position)
	if GameMap.current_tilemap_node.cell_entities.has(current_pos):
		GameMap.current_tilemap_node.cell_entities.erase(current_pos)
	self.queue_free()

func set_hp(new_value: int):
	HP = new_value
	if health_bar:
		health_bar.value = HP

func set_dmg(new_value: String):
	DMG = new_value

func calc_dmg(dmg_str: String):
	# Parse the DMG string to diceroll
	var total_dmg: int = 0
	var dice_data = dmg_str.split("d")
	if dice_data.size() == 2:
		for i in range(int(dice_data[0])):
			total_dmg += randi_range(1, int(dice_data[1]))
	print(total_dmg)
	return total_dmg
	

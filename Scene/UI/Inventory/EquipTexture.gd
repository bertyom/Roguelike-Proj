extends TextureRect

@onready var icon = get_child(0)
@onready var slot_name = get_name()

func _ready():
	if icon.texture == null:
		texture = load("res://Image/UI/Inventory/Slots/"+slot_name+".png")
	else:
		texture = load("res://Image/UI/Inventory/Slots/Empty.png")

func _on_Icon_draw():
	if icon.texture == null:
		texture = load("res://Image/UI/Inventory/Slots/"+slot_name+".png")
	else:
		texture = load("res://Image/UI/Inventory/Slots/Empty.png")

extends CanvasLayer
@onready var inventory = $Control/Inventory
@onready var cont_control = $Control


signal inventory_open
signal inventory_closed

func _ready():
	CommonFunctions.UI_node = cont_control
	#inventory_closed.connect(SceneHandler._on_inventory_closed)

func _physics_process(_delta):
	if Input.is_action_just_pressed("UI_INVENTORY") and inventory.visible == false:
		emit_signal("inventory_open")
		inventory.visible = true
	elif Input.is_action_just_pressed("UI_INVENTORY") and inventory.visible == true:
		inventory.visible = false
		emit_signal("inventory_closed")

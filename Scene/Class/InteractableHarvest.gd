extends Interactable
class_name InteractableHarvest

@export var item_id: String
@export var item_amount: int
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func start_interaction():
	CommonFunctions._add_item(item_id, item_amount)
	_on_interaction_exited()
	animation_player.play("Harvest")
	interaction_shape.disabled = true

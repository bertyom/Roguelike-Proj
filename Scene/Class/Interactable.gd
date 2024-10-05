extends StaticBody2D
class_name Interactable

@onready var sprite = $Sprite
@onready var interaction_shape: CollisionShape2D = $InteractionShape
@export var should_outline: = true
@export var should_animate: = true

func _on_interaction_entered():
	if should_outline:
		sprite.material.set_shader_parameter("width", 1)
	
func _on_interaction_exited():
	sprite.material.set_shader_parameter("width", 0)
		
func start_interaction():
	print("Hello there")
	

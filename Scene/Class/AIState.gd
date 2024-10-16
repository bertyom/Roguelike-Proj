extends Node
class_name AI_State

@export_enum("Passive", "Agressive", "Attacking", "None") var behaviour_type: String
@export var controlled_body: CharacterBody2D
@export var weapon: EnemyWeaponBase
@export var nav_agent: NavigationAgent2D

func _ready():
	set_physics_process(false)

func enter():
	call_deferred("_try_setup")
	set_physics_process(true)
	
func exit():
	set_physics_process(false)

func _try_setup():
	if self.has_method("setup"):
		self.setup()

func setup(): #Override in each state
	pass

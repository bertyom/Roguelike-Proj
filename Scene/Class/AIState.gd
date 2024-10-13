extends Node
class_name AI_State

@export_enum("Passive", "Agressive", "None") var behaviour_type: String
var controlled_body: CharacterBody2D
var weapon: EnemyWeaponBase
var nav_agent: NavigationAgent2D

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

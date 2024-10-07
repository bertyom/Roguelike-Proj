extends Node

@onready var parent_node = $"../.."
@onready var navigation_agent = $"../../NavigationAgent2D"
var direction
var target_location
var navigation_node
var weapon
var can_attack = true
var currently_swinging = false
@export_enum("Passive", "Agressive", "None") var behaviour_type: String

func start():
	_setup()
	
func _setup():
	await get_tree().physics_frame
	navigation_agent.path_desired_distance = 4.0
	navigation_agent.target_desired_distance = 4.0
	randomize()
	weapon = parent_node.current_weapon
	if !weapon.attack_timer.timeout.is_connected(_on_AttackTimer_timeout):
		weapon.attack_timer.timeout.connect(_on_AttackTimer_timeout)
	if !weapon.attack_finished.is_connected(_on_attack_finished):
		weapon.attack_finished.connect(_on_attack_finished)


func _attack():
	can_attack = false
	if parent_node.velocity.x >= 0:
		weapon.anim_state_machine.travel("RightWindup")
	else:
		weapon.anim_state_machine.travel("LeftWindup")
	weapon.attack_timer.start()
	currently_swinging = true


func _physics_process(delta):
	navigation_agent.target_position = PlayerData.player_node.global_position
	
	var current_agent_position: Vector2 = parent_node.global_position
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	var new_velocity: Vector2 = (next_path_position - current_agent_position).normalized() * parent_node.movement_speed
	parent_node.velocity = new_velocity

	if can_attack:
		_attack()

	# Move towards the waypoint
	if !currently_swinging:
		if parent_node.velocity.x >= 0:
			parent_node.anim_tree.travel("R_Walk")
		else:
			parent_node.anim_tree.travel("L_Walk")
	else:
		if parent_node.facing_right:
			parent_node.anim_tree.travel("R_Walk")
		else:
			parent_node.anim_tree.travel("L_Walk")
	
	parent_node.move_and_slide()

func _on_AttackTimer_timeout():
	can_attack = true

func _on_attack_finished():
	currently_swinging = false

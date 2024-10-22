extends Node
class_name AI_State

@export_enum("Passive", "Agressive", "Attacking", "Dying", "None") var behaviour_type: String
@export var controlled_body: CharacterBody2D
@export var weapon: EnemyWeaponBase
@export var nav_agent: NavigationAgent2D
@export var min_distance_threshold: float = 15.0  #Minimum distance to the player

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

func update_pathfinding(target_position: Vector2):
	if nav_agent:
		nav_agent.target_position = target_position

func move_towards_target() -> Vector2:
	if nav_agent:
		var current_agent_position: Vector2 = controlled_body.global_position
		var next_path_position: Vector2 = nav_agent.get_next_path_position()
		var new_velocity: Vector2 = (next_path_position - current_agent_position).normalized() * controlled_body.movement_speed
		controlled_body.velocity = new_velocity
		return new_velocity
	return Vector2.ZERO

func move_towards_player() -> Vector2:
	if PlayerData.player_node:
		update_pathfinding(PlayerData.player_node.global_position)
		var distance_to_player = get_distance_to_player()
		if distance_to_player > min_distance_threshold:
			return move_towards_target()
		else:
			controlled_body.velocity = Vector2.ZERO
			return Vector2.ZERO
	return Vector2.ZERO

func move_towards_waypoint(waypoint: Vector2) -> Vector2:
	update_pathfinding(waypoint)
	return move_towards_target()

func get_distance_to_player() -> float:
	if PlayerData.player_node:
		return controlled_body.global_position.distance_to(PlayerData.player_node.global_position)
	return INF

func is_navigation_finished() -> bool:
	return nav_agent.is_navigation_finished() if nav_agent else true

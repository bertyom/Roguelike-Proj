extends Player

#region Variables
enum MovementState {IDLE, WALK, SPRINT, DASH}
enum AttackState {IDLE, ATTACKING}

@export var walk_speed := 300.0
@export var sprint_speed := 450.0
@export var dash_speed := 1700.0
@export var attack_speed_multiplier := 0.5
@export var unmatching_direction_speed_multiplier: = 0.7
@export var dash_duration := 0.07
@export var dash_cooldown := 1.0
@export var interaction_distance := 50.0

#Movement and state variables
var movement_state: MovementState = MovementState.IDLE
var attack_state: AttackState = AttackState.IDLE
var input_vector := Vector2.ZERO
var mouse_position := Vector2.ZERO
var dash_direction := Vector2.ZERO
var mouse_vector := Vector2.ZERO
var matching_directions: bool

#Node references
@onready var interaction_raycast: RayCast2D = $InteractionRaycast
@onready var body_animation_player := $Sprites/AnimationPlayer
@onready var body_sprite: Sprite2D = $Sprites/Body
@onready var weapon_manager: Node2D = $WeaponManager
@onready var dash_timer: Timer = %Dash
@onready var dash_cooldown_timer: Timer = %"Dash Cooldown"
@onready var soft_collision: Area2D = $SoftCollision

#Helper variables
@export var interacted_object: Interactable = null
#endregion

func _ready():
	dash_timer.wait_time = dash_duration
	dash_cooldown_timer.wait_time = dash_duration + dash_cooldown
	
	dash_timer.connect("timeout", _on_dash_timer_timeout)
	weapon_manager.connect("attack_state_changed", _on_attack_state_changed)

	PlayerData.player_node = self
	
func _physics_process(_delta):
	_handle_input()
	_manage_interaction_raycast()
	_update_movement_state()
	_update_sprites_and_animations()
	_move()
	apply_soft_collisions()
	move_and_slide()
	

func _update_movement_state():
	if movement_state == MovementState.DASH:
		return

	if input_vector == Vector2.ZERO:
		movement_state = MovementState.IDLE
	elif Input.is_action_pressed("MOVE_SPRINT") and attack_state == AttackState.IDLE:
		movement_state = MovementState.SPRINT
	else:
		movement_state = MovementState.WALK

#region Consolidated input
func _handle_input():
	_vector_and_mouse_input()
	_dash_input()
	_attack_input()
	_interaction_input()

func _vector_and_mouse_input():
	input_vector = Input.get_vector("MOVE_LEFT", "MOVE_RIGHT", "MOVE_UP", "MOVE_DOWN")
	mouse_position = get_global_mouse_position()
	mouse_vector = (mouse_position - global_position).normalized()
	matching_directions = (input_vector.x >= 0) == (mouse_vector.x >= 0)
#endregion

func _update_sprites_and_animations():
	if attack_state == AttackState.IDLE and CommonFunctions.inventory_node.visible == false:
		body_sprite.flip_h = mouse_vector.x < 0
	
	var animation = "Idle"
	if movement_state in [MovementState.WALK, MovementState.SPRINT]:
		animation = "Walk" if matching_directions else "Walk_Back"
	elif movement_state == MovementState.DASH:
		if matching_directions or input_vector.x == 0:
			animation = "Dash" 
		else:
			animation = "Dash_Back"

	body_animation_player.play(animation)

	var speed_scale = 1.0
	if movement_state == MovementState.SPRINT:
		speed_scale = sprint_speed / walk_speed
	else:
		speed_scale = 1.0
	
	if !matching_directions and movement_state != MovementState.DASH:
		speed_scale *= unmatching_direction_speed_multiplier
	
	if attack_state != AttackState.IDLE:
		speed_scale *= attack_speed_multiplier
	
	body_animation_player.speed_scale = speed_scale

func _move():
	var speed = walk_speed
	match movement_state:
		MovementState.SPRINT:
			speed = sprint_speed
		MovementState.DASH:
			speed = dash_speed

	if !matching_directions and movement_state != MovementState.DASH:
		speed *= unmatching_direction_speed_multiplier
	
	if attack_state != AttackState.IDLE:
		speed *= attack_speed_multiplier
	
	if movement_state == MovementState.DASH:
		velocity = dash_direction * speed
	else:
		velocity = input_vector * speed

func apply_soft_collisions():
	var push_vector = soft_collision.get_push_vector()
	if push_vector != Vector2.ZERO:
		velocity += push_vector

#region Dash logic
func _dash_input():
	if Input.is_action_just_pressed("MOVE_DASH") and movement_state != MovementState.DASH and dash_cooldown_timer.is_stopped() and attack_state == AttackState.IDLE:
		_initiate_dash()

func _initiate_dash():
	movement_state = MovementState.DASH
	if input_vector != Vector2.ZERO:
		dash_direction = input_vector
	else:
		dash_direction = mouse_vector
	dash_timer.start()
	dash_cooldown_timer.start()
	
func _on_dash_timer_timeout():
	movement_state = MovementState.IDLE
	dash_direction = Vector2.ZERO
#endregion

#region Attack logic
func _attack_input():
	if CommonFunctions.inventory_node.visible == false:
		if Input.is_action_just_pressed("WEAPON_ATTACK") and attack_state == AttackState.IDLE:
			weapon_manager.start_attack()
		elif Input.is_action_just_released("WEAPON_ATTACK") and attack_state != AttackState.IDLE:
			weapon_manager.end_attack()

func _on_attack_state_changed(is_attacking: bool):
	if is_attacking:
		attack_state = AttackState.ATTACKING
	else:
		attack_state = AttackState.IDLE
#endregion

#region Prop interaction logic
func _manage_interaction_raycast():
	interaction_raycast.target_position = mouse_vector * interaction_distance
	var collider = interaction_raycast.get_collider()
	if collider is Interactable:
		if interacted_object != collider:
			if interacted_object:
				interacted_object._on_interaction_exited()
			interacted_object = collider
			interacted_object._on_interaction_entered()
	elif interacted_object:
		interacted_object._on_interaction_exited()
		interacted_object = null
		
func _interaction_input():
	if Input.is_action_just_pressed("CHR_INTERACT") and interacted_object:
		interacted_object.start_interaction()
#endregion

extends CharacterBody2D

#region Variables
#State machine enums
enum PlayerStates {IDLE, WALK, SPRINT, DASH, ATTACK}
enum WeaponStates {NONE, FIRST, SECOND}

#Player stats
@export var walk_speed := 300.0
@export var sprint_speed := 600.0
@export var dash_speed := 1000.0
@export var dash_duration := 0.2
@export var dash_cooldown := 1.0

#State variables
var current_state: int = PlayerStates.IDLE
var current_weapon: int = WeaponStates.NONE

# Input variables
@export var input_vector := Vector2.ZERO
@export var mouse_position := Vector2.ZERO
@export var dash_direction := Vector2.ZERO
@export var mouse_vector: = Vector2.ZERO
@export var matching_directions:=  true
@export var attack_lock_controls:= false

# Node references
@onready var body_animation_player := $Sprites/AnimationPlayer
@onready var body_sprite: Sprite2D = $Sprites/Body
@onready var weapon_manager: Node2D = $WeaponManager
@onready var dash_timer: Timer = %Dash
@onready var dash_cooldown_timer: Timer = %"Dash Cooldown"
#endregion

func _ready():
	dash_timer.wait_time = dash_duration
	dash_cooldown_timer.wait_time = dash_duration + dash_cooldown
	
	dash_timer.connect("timeout", _on_dash_timer_timeout)
	weapon_manager.connect("attack_state_changed", _on_attack_state_changed)

func _physics_process(delta):
	_handle_input()
	_update_state()
	_update_sprites_and_animations()
	_move()

func _update_state():
	if current_state == PlayerStates.DASH:
		return

	if input_vector == Vector2.ZERO:
		current_state = PlayerStates.IDLE
	elif Input.is_action_pressed("MOVE_SPRINT") and !attack_lock_controls:
		current_state = PlayerStates.SPRINT
	else:
		current_state = PlayerStates.WALK

func _handle_input():
	input_vector = Vector2(
	Input.get_action_strength("MOVE_RIGHT") - Input.get_action_strength("MOVE_LEFT"), 
	Input.get_action_strength("MOVE_DOWN") - Input.get_action_strength("MOVE_UP")
	).normalized()
	
	mouse_position = get_global_mouse_position()
	mouse_vector = (mouse_position - global_position).normalized()

	if Input.is_action_just_pressed("MOVE_DASH") and current_state != PlayerStates.DASH and dash_cooldown_timer.is_stopped():
		_initiate_dash()
		
	if Input.is_action_just_pressed("WEAPON_ATTACK"):
		weapon_manager.start_attack()
		current_state = PlayerStates.ATTACK
	elif Input.is_action_just_released("WEAPON_ATTACK"):
		current_state = PlayerStates.IDLE

func _update_sprites_and_animations():
	if !attack_lock_controls:
		body_sprite.flip_h = mouse_vector.x < 0
	var matching_directions = (input_vector.x >= 0) == (mouse_vector.x >= 0)
	var matching_direction_animation = "" if matching_directions else "_Back"

	var animation = "Idle"
	match current_state:
		PlayerStates.SPRINT, PlayerStates.WALK:
			animation = "Walk"+matching_direction_animation
		PlayerStates.DASH:
			animation = "Dash"+matching_direction_animation
		PlayerStates.ATTACK:
			if input_vector != Vector2.ZERO:
				animation = "Walk"+matching_direction_animation
	
	body_animation_player.play(animation)
		
#region Movement
func _move():
	var speed = walk_speed
	match current_state:
		PlayerStates.SPRINT:
			speed = sprint_speed
		PlayerStates.DASH:
			speed = dash_speed
	
	if current_state == PlayerStates.DASH:
		velocity = dash_direction * speed
	else:
		velocity = input_vector * speed

	move_and_slide()

func _initiate_dash():
	if !attack_lock_controls:
		current_state = PlayerStates.DASH

		if input_vector != Vector2.ZERO:
			dash_direction = input_vector
		else:
			dash_direction = (mouse_position - global_position).normalized()

		dash_timer.start()
		dash_cooldown_timer.start()

func _on_dash_timer_timeout():
	current_state = PlayerStates.IDLE
	dash_direction = Vector2.ZERO
#endregion

func _on_attack_state_changed(is_attacking: bool):
	attack_lock_controls = is_attacking

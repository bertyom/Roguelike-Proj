extends CharacterBody2D

#region Variables
#State machine enums
enum PlayerStates {IDLE, WALK, SPRINT, DASH, ATTACK}
enum WeaponStates {NONE, MELEE, RANGED}

#Player stats
@export var walk_speed := 100.0
@export var sprint_speed := 200.0
@export var dash_speed := 500.0
@export var dash_duration := 0.2
@export var dash_cooldown := 1.0

#State variables
var current_state: int = PlayerStates.IDLE
var current_weapon: int = WeaponStates.NONE

# Input variables
@export var input_vector: Vector2 = Vector2.ZERO
@export var mouse_position: Vector2 = Vector2.ZERO

# Node references
@onready var body_animation_tree: AnimationTree = $Sprites/AnimationTree
@onready var animation_player := $AnimationPlayer
@onready var body_sprite: Sprite2D = $Sprites/Body
@onready var weapon_manager: Node2D = $WeaponManager
@onready var dash_timer: Timer = %Dash
@onready var dash_cooldown_timer: Timer = %"Dash Cooldown"
#endregion

func _ready():
	dash_timer.wait_time = dash_duration
	dash_cooldown_timer.wait_time = dash_cooldown

func _physics_process(delta):
	_handle_input()
	_update_state()
	_move()

func _handle_input():
	input_vector = Vector2(
	Input.get_action_strength("MOVE_RIGHT") - Input.get_action_strength("MOVE_LEFT"), 
	Input.get_action_strength("MOVE_DOWN") - Input.get_action_strength("MOVE_UP")
	).normalized()
	
	mouse_position = get_global_mouse_position()

func _move():
	var speed = walk_speed
	if current_state == PlayerStates.SPRINT:
		speed = sprint_speed
	elif current_state == PlayerStates.DASH:
		speed = dash_speed
	
	velocity = input_vector * speed
	move_and_slide()

func _update_state():
	if current_state == PlayerStates.DASH:
		return

	if input_vector == Vector2.ZERO:
		current_state = PlayerStates.IDLE
	elif Input.is_action_pressed("MOVE_SPRINT"):
		current_state = PlayerStates.SPRINT
	else:
		current_state = PlayerStates.WALK

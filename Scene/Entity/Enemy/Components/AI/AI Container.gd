extends Node

@export var states = []

@export var active_state: AI_State
@export var previous_state: AI_State
@onready var parent_node: CharacterBody2D
@onready var state_timer: Timer = $"State Timer"

func _ready():
	await get_tree().process_frame
	setup_states()
	for child in get_children():
		if child is AI_State:
			child.controlled_body = parent_node
	active_state.enter()

func setup_states():
	for state in get_children():
		if state is AI_State:
			states.append(state.name)

func change_state(new_state: String):
	if active_state:
		active_state.exit()
	
	active_state = self.get_node(new_state)
	active_state.enter()

func temp_change_state(new_state: String, duration: float):
	previous_state = active_state
	change_state(new_state)
	state_timer.start(duration)

func _on_state_timer_timeout():
	if previous_state:
		change_state(previous_state.name)
		previous_state = null

extends Node2D

class_name WindingPathWalker

var width: int
var height: int
var num_rooms: int
var min_room_size: int
var max_room_size: int
var grid: Array

func _ready() -> void:
	_init(80, 80, 10, 5, 10)

func _init(_width: int, _height: int, _num_rooms: int, _min_room_size: int, _max_room_size: int):
	width = _width
	height = _height
	num_rooms = _num_rooms
	min_room_size = _min_room_size
	max_room_size = _max_room_size
	grid = []

func generate() -> Array:
	# Initialize grid
	for x in range(width):
		grid.append([])
		for y in range(height):
			grid[x].append(0)  # 0 represents empty space

	var walker = Vector2(width / 2, height / 2)
	var direction = Vector2.RIGHT
	var turns_since_last_room = 0

	for i in range(num_rooms):
		# Create a room
		var room_size = Vector2(
			randi() % (max_room_size - min_room_size + 1) + min_room_size,
			randi() % (max_room_size - min_room_size + 1) + min_room_size
		)
		create_room(walker, room_size)

		# Move the walker
		var steps = randi() % 10 + 5  # Random number of steps between 5 and 14
		for j in range(steps):
			if turns_since_last_room > 2 or randf() < 0.2:  # 20% chance to turn, or turn if we haven't in a while
				direction = direction.rotated(PI / 2 if randf() < 0.5 else -PI / 2)
				turns_since_last_room = 0
			else:
				turns_since_last_room += 1

			walker += direction
			walker.x = clamp(walker.x, 1, width - 2)
			walker.y = clamp(walker.y, 1, height - 2)
			grid[walker.x][walker.y] = 1  # Mark the path

	return grid

func create_room(position: Vector2, size: Vector2):
	for x in range(max(0, position.x - size.x / 2), min(width, position.x + size.x / 2)):
		for y in range(max(0, position.y - size.y / 2), min(height, position.y + size.y / 2)):
			grid[x][y] = 1  # Mark as room

# Example usage
# var walker = WindingPathWalker.new(80, 80, 10, 5, 10)
# var dungeon = walker.generate()

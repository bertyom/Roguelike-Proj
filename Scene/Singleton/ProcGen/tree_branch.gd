extends Node
class_name Branch

var child_l: Branch
var child_r: Branch
var position: Vector2i
var size: Vector2i


func _init(starting_position, starting_size):
	self.position = starting_position
	self.size = starting_size

func split(remaining, paths: Array):
	var rng = RandomNumberGenerator.new()
	var split_percent = rng.randf_range(0.3,0.7)
	var split_horizontal = size.y >= size.x
	
	# split current leaf
	if(split_horizontal):
		var left_height = int(size.y * split_percent)
		child_l = Branch.new(position, Vector2i(size.x, left_height))
		child_r = Branch.new(Vector2i(position.x,position.y + left_height), 
		Vector2i(size.x,size.y - left_height))
	else:
		var left_width = int(size.x * split_percent)
		child_l = Branch.new(position, Vector2i(left_width,size.y))
		child_r = Branch.new(Vector2i(position.x + left_width,position.y), 
		Vector2i(size.x - left_width,size.y))
	
	paths.push_back({'left': child_l.get_center(), 'right': child_r.get_center()})
	
	if(remaining > 0):
		child_l.split(remaining - 1, paths)
		child_r.split(remaining - 1, paths)
	
func get_leaves():
	if not (child_l && child_r):
		return [self]
	else:
		return child_l.get_leaves() + child_r.get_leaves()
		
func get_center():
	return Vector2i(position.x + size.x / 2, position.y + size.y / 2)

extends StaticBody2D

var sprite: Sprite2D

func _setup(copied_body: CharacterBody2D):
	sprite = get_node("Sprite")
	# Set the sprite to be exactly the same as the enemy's current one
	sprite.texture = copied_body.sprite.texture
	sprite.hframes = copied_body.sprite.hframes
	sprite.vframes = copied_body.sprite.vframes
	sprite.frame = copied_body.sprite.frame
	sprite.flip_h = copied_body.sprite.flip_h
	sprite.centered = copied_body.sprite.centered

	# Set the position of the dead body to match the enemy's position
	global_position = copied_body.global_position
	sprite.position = copied_body.sprite.position

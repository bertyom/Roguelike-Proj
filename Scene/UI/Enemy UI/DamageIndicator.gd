extends Label

@onready var anim_player = $AnimationPlayer

func start(value):
	text = str(value)
	anim_player.play("Fade")

func _process(delta):
	if anim_player.is_playing():
		position.y -= delta * 50

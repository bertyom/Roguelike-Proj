extends TextureRect
@onready var anim_player = $AnimationPlayer

func start():
	anim_player.play("PopUp")

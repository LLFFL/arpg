extends AnimatedSprite2D

func _ready():
	self.connect('animation_finished', _on_animation_finished)
	play("Animate")

	


func _on_animation_finished() -> void:
	queue_free()

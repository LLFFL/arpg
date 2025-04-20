extends Control


@export var sprite_texture:Texture2D
@export var sound:AudioStream
@export var credit = "name"
var tween:Tween

func _ready():
	$AudioStreamPlayer2D.stream = sound
	$Label.text = credit
	

func _on_pressed():
	$AudioStreamPlayer2D.play()
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self,"scale:y",1.5,0.05).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self,"scale:y",1.1,0.05).set_ease(Tween.EASE_OUT)
	

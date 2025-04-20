class_name MidwayPoint extends StaticBody2D
@onready var texture_progress_bar: TextureProgressBar = $TextureProgressBar
@onready var boss_module: Area2D = $BossModule

@export var health: float = 500:
	set(value):
		health = value
		texture_progress_bar.value = health
		if health <= 0:
			queue_free()
	get():
		return health
@onready var hurt_box: HurtBox = $HurtBox

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	texture_progress_bar.max_value = health
	texture_progress_bar.value = health
	
	hurt_box.damaged.connect(damage)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func damage(_attack: Attack):
	var dmg = _attack.damage
	health -= dmg if dmg > 0 else 0
	
	var t = create_tween()
	t.tween_property($Sprite2D,"scale:y",1.3,0.05).set_trans(Tween.TRANS_LINEAR)
	t.parallel().tween_property($Sprite2D,"modulate",Color("faa6c6"),0.05).set_trans(Tween.TRANS_LINEAR)
	t.tween_property($Sprite2D,"scale:y",1,0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property($Sprite2D,"modulate",Color("white"),0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	$AudioStreamPlayer2D.play()
	await t.finished
	t.kill()
	$Sprite2D.scale.y = 1

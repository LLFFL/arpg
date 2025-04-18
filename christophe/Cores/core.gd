extends StaticBody2D

@export var Sprite:Texture2D
@export var Shadow:Color
@export var HitColor:Color
@export var is_player_core = false


var _dmg_tween:Tween

func _ready():
	$CoreSprite.texture = Sprite
	$CoreShadow.modulate = Shadow
	%HitParticles.modulate = HitColor
	
	# wont play if its the player core
	if not is_player_core:
		$ShakerIdle.play_shake()
	else:
		self.z_index = -2
		
		
	#$CoreShadow.modulate.a = 0.5


func play_hit_animation():
	if is_player_core: 
		play_player_core_hit_animation()
		return
	if _dmg_tween:
		#$CoreSprite.modulat
		_dmg_tween.kill()
		$CoreSprite.scale.y = 1
		$CoreSprite.position.y = 32
	if !%HitParticles.emitting:
		%HitParticles.restart()
	
	_dmg_tween = create_tween()
	_dmg_tween.tween_property($CoreSprite,"modulate",HitColor,0.01).set_ease(Tween.EASE_OUT)
	
	_dmg_tween.parallel().tween_property($CoreSprite,"scale:y",1.2,0.05).set_ease(Tween.EASE_OUT)
	_dmg_tween.parallel().tween_property($CoreSprite,"position:y",$CoreSprite.position.y - 10,0.2).set_ease(Tween.EASE_OUT)
	
	_dmg_tween.tween_property($CoreSprite,"modulate",Color("white"),0.2).set_ease(Tween.EASE_IN)
	
	_dmg_tween.parallel().tween_property($CoreSprite,"scale:y",1,0.05).set_ease(Tween.EASE_IN)
	_dmg_tween.parallel().tween_property($CoreSprite,"position:y",32,0.2).set_ease(Tween.EASE_OUT)

func play_player_core_hit_animation():
	$PlayerCoreShake.play_shake()
	if _dmg_tween:
		#$CoreSprite.modulat
		_dmg_tween.kill()
	#if !%HitParticles.emitting:
	#	%HitParticles.restart()
	
	_dmg_tween = create_tween()
	_dmg_tween.tween_property($CoreSprite,"modulate",HitColor,0.01).set_ease(Tween.EASE_OUT)

	_dmg_tween.tween_property($CoreSprite,"modulate",Color("white"),0.2).set_ease(Tween.EASE_IN)

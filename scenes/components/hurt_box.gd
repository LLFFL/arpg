class_name HurtBox extends Area2D

const HitEffect = preload("res://assets/Action RPG Resources/Effects/HitEffect.tscn")
signal invincibility_started
signal invincibility_ended
signal damaged
signal damaged2
@onready var timer = $Timer
@onready var collisionShape = $CollisionShape2D


"""When you instantiate this in another scene remember to turn on editable children by right clicking hurtbox in the scene
thing and checking it then giving the specific enemy its own hitbox"""

var invincible = false:
	get():
		return invincible
	set(value):
		invincible = value
		if invincible:
			emit_signal('invincibility_started')
		else:
			emit_signal('invincibility_ended')

func create_hit_effect() -> void:
	var effect = HitEffect.instantiate()
	var main = get_tree().current_scene
	main.add_child(effect)
	effect.global_position = global_position
#dont remember exactly why it was done this way, probably to stop hit effect from playing on everything that inherited it
#when one thing got hit
func start_invincibility(duration):
	invincible = true
	timer.start(duration)

func _on_timer_timeout() -> void:
	invincible = false


func _on_invincibility_started() -> void:
	pass
	#print('invincibility starts')
	#set_deferred("monitorable", false)
#has to be deferred to take effect on end of frame because changing it in the middle of the frame will mess up the physics

func _on_invincibility_ended() -> void:
	pass
	#set_deferred("monitorable", true)

#take damage function, to call parent and do damage
#Added bat to layer 4 so its seen by projectile on layer 4

func damage(attack: Attack) -> void:
	#print("Player hit")
	if !invincible:
		damaged.emit(attack)


func damage2(projectile: InstancedProjectile2D):
	damaged2.emit(projectile.resource.damage)

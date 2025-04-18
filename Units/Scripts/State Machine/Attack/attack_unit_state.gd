class_name AttackUnitState extends UnitState
@onready var chase: ChaseUnitState = $"../Chase"
@onready var attack_zone: Area2D = $"../../AttackZone"

var attacking: bool = false

func init():
	super()
	attack_zone.connect("area_exited", _on_target_exit_zone)


func _ready() -> void:
	pass

func enter() -> void:
	attacking = true
	unit.update_anim("wind_up")
	unit.animation_player.animation_finished.connect(attack_target)
	pass


func exit() -> void:
	if unit.animation_player.animation_finished.is_connected(attack_target):
		unit.animation_player.animation_finished.disconnect(attack_target)
	if unit.animation_player.animation_finished.is_connected(_on_animation_finished):
		unit.animation_player.animation_finished.disconnect(_on_animation_finished)
	pass

func process( _delta: float ) -> UnitState:
	if !attacking:
		return chase
	unit.velocity = Vector2.ZERO
	return null

func physics( _delta: float ) -> UnitState:
	return null

func handle_input( _event: InputEvent ) -> UnitState:
	return null

func _on_target_exit_zone(_area: Area2D):
	pass
	#return chase

func attack_target(name: String):
	var overlaps = attack_zone.get_overlapping_areas()
	#THIS IS STUPID I KNOW BUT RENAMING THE HURTBOX ON PLAYER WOULD BE A PAIN TO DEBUG
	if unit.temp_target:
		if unit.temp_target is Player:
			if !overlaps.has(unit.temp_target.hurtbox):
				attacking = false
				return
		else:
			if !overlaps.has(unit.temp_target.hurt_box):
				attacking = false
				return
	unit.animation_player.animation_finished.disconnect(attack_target)
	unit.update_anim("attack")
	unit.animation_player.animation_finished.connect(_on_animation_finished)
	pass

func _on_animation_finished(name: String):
	attacking = false

func jump_to_target():
	if !unit.temp_target:
		return
	var tween = create_tween()
	var curr_pos = unit.global_position
	tween.tween_property(unit, "global_position", unit.temp_target.global_position, 0.7)
	tween.tween_callback(jump_back.bind(curr_pos))
	pass

func jump_back(_pos: Vector2):
	var tween = create_tween()
	tween.tween_property(unit, "global_position", _pos, 0.3)
	pass

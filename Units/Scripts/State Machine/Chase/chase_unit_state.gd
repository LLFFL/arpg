class_name ChaseUnitState extends UnitState
@onready var enemy_detection_zone: Area2D = $"../../EnemyDetectionZone"
@onready var attack: AttackUnitState = $"../Attack"

func _ready() -> void:
	enemy_detection_zone.connect("body_entered", _on_body_enter)
	enemy_detection_zone.connect("body_exited", _on_body_exit)
	pass

func enter() -> void:
	unit.update_anim("walk")
	#if unit.temp_target:
		#unit.direction = Vector2.LEFT if unit.global_position.direction_to(unit.temp_target.global_position).x < 0 else Vector2.RIGHT
	#else:
		#unit.direction = Vector2.LEFT if unit.global_position.direction_to(unit.target_location).x < 0 else Vector2.RIGHT
	#unit.velocity = unit.stats.movement_speed * unit.direction
	pass


func exit() -> void:
	pass

func process( _delta: float ) -> UnitState:	
	if unit.temp_target:
		unit.direction = unit.global_position.direction_to(unit.temp_target.global_position).normalized()
	else:
		unit.direction = unit.global_position.direction_to(unit.target_location).normalized()
	unit.velocity = unit.stats.movement_speed * unit.direction
	return null

func physics( _delta: float ) -> UnitState:
	return null

func handle_input( _event: InputEvent ) -> UnitState:
	return null

func _on_body_enter(_body: Node2D):
	if _body is CharacterBody2D:
		unit.temp_target = _body
		#return attack
	pass

func _on_body_exit(_body: Node2D):
	if _body is CharacterBody2D:
		unit.temp_target = null

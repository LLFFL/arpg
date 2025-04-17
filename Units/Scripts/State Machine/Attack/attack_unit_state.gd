class_name AttackUnitState extends UnitState
@onready var enemy_detection_zone: Area2D = $"../../EnemyDetectionZone"
@onready var chase: ChaseUnitState = $"../Chase"


func _ready() -> void:
	enemy_detection_zone.connect("body_exited", _on_body_exit)
	pass

func enter() -> void:
	pass


func exit() -> void:
	pass

func process( _delta: float ) -> UnitState:
	return null

func physics( _delta: float ) -> UnitState:
	return null

func handle_input( _event: InputEvent ) -> UnitState:
	return null

func _on_body_exit(_body: Node2D):
	if _body == unit.temp_target:
		return chase
	pass

class_name ChaseUnitState extends UnitState
@onready var enemy_detection_zone: Area2D = $"../../EnemyDetectionZone"
@onready var attack: AttackUnitState = $"../Attack"
@onready var attack_zone: Area2D = $"../../AttackZone"
@onready var struct_zone: Area2D = $"../../StructZone"
@onready var suicide: SuicideUnitState = $"../Suicide"

var chasing: bool = true

func init():
	super()
	attack_zone.collision_mask = unit.hitbox.collision_mask
	if unit.ally:
		struct_zone.set_collision_mask_value(18, true)
	else:
		struct_zone.set_collision_mask_value(17, true)

func _ready() -> void:
	pass

func enter() -> void:
	struct_zone.connect("area_entered", _on_area_enter)
	struct_zone.connect("area_exited", _on_area_exit)
	enemy_detection_zone.connect("body_entered", _on_body_enter)
	enemy_detection_zone.connect("body_exited", _on_body_exit)
	attack_zone.connect("area_entered", _on_target_enter_zone)
	chasing = true
	unit.update_anim("walk")
	unit.stats.damage_modifier = 3
	pass


func exit() -> void:
	struct_zone.disconnect("area_entered", _on_area_enter)
	struct_zone.disconnect("area_exited", _on_area_exit)
	enemy_detection_zone.disconnect("body_entered", _on_body_enter)
	enemy_detection_zone.disconnect("body_exited", _on_body_exit)
	attack_zone.disconnect("area_entered", _on_target_enter_zone)
	chasing = false
	pass

func process( _delta: float ) -> UnitState:
	if unit.struct_target:
		return suicide
	if !chasing:
		return attack
	unit.targets = unit.targets.filter(func(element): return element != null)
	
	
	var overlaps = attack_zone.get_overlapping_areas()
	for _area in overlaps:
		if _area is HurtBox:
			if _area.get_parent() == unit.temp_target:
				return attack 
	
	if unit.temp_target:
		unit.direction = unit.global_position.direction_to(unit.temp_target.global_position).normalized()
	else:
		unit.direction = Vector2.LEFT if unit.global_position.direction_to(unit.target_location).normalized().x < 0 else Vector2.RIGHT
	unit.velocity = unit.stats.movement_speed * unit.direction
	return null

func physics( _delta: float ) -> UnitState:
	return null

func handle_input( _event: InputEvent ) -> UnitState:
	return null

func _on_body_enter(_body: Node2D):
	if _body is CharacterBody2D:
		unit.targets.append(_body)
		#return attack
	pass

func _on_body_exit(_body: Node2D):
	if _body is CharacterBody2D:
		var i = unit.targets.find(_body)
		if i >= 0:
			unit.targets.remove_at(i)

func _on_target_enter_zone(_area: Area2D):
	return
	if _area is HurtBox:
		unit.temp_target = _area.get_parent()
		chasing = false

func _on_area_enter(_area: Area2D):
	unit.struct_target = _area
	pass
func _on_area_exit(_area: Area2D):
	unit.struct_target = null
	pass

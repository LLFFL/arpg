extends Control
@onready var l_side_core: TextureProgressBar = $"HBoxContainer/LSide Core HP"
@onready var r_side_core: TextureProgressBar = $"HBoxContainer/RSide Core HP"
@onready var player_core: TextureProgressBar = $"Player Core HP"

@onready var player_hp: TextureProgressBar = $PlayerHP
@onready var player: Player = $"../../../../Player"

@onready var gold1: Label = $Gold
@onready var right_danger: Sprite2D = $RightDanger
@onready var left_danger: Sprite2D = $LeftDanger



func _ready():
	await get_tree().create_timer(1).timeout
	PlayerManager.player.stats.onGoldChange.connect(update_gold)


	
	pass
	
func initialize_health(max_hp: float, sender: Node2D) -> void:
	if sender.MainBase:
		player_core.max_value = max_hp
	elif sender.LeftBase:
		l_side_core.max_value = max_hp
	else: r_side_core.max_value = max_hp



func on_health_changed(current_hp: float, sender: Node2D) -> void:
	if sender.MainBase:
		player_core.value = current_hp

	elif sender.LeftBase:
		l_side_core.value = current_hp
		$"HBoxContainer/LSide Core HP/LSideLabel".text = str(int(current_hp))
	else: 
		r_side_core.value = current_hp
		$"HBoxContainer/RSide Core HP/RSide Label".text = str(int(current_hp))


func initialize_health_player(max_hp: float,) -> void:
	player_hp.max_value = max_hp
	PlayerManager.player.get_node("%PlayerHPUi").max_value = max_hp

func on_health_changed_player(current_hp: float) -> void:
	player_hp.value = current_hp
	PlayerManager.player.get_node("%PlayerHPUi").value = current_hp

func update_gold(gold: int) -> void:
	gold1.text = str(gold)

func flash_danger():
	var tween = create_tween().set_loops(3)
	tween.tween_property(right_danger, 'modulate:a', 1, 0.3)
	tween.tween_property(right_danger, 'modulate:a', 0, 0.3)
	tween.tween_property(left_danger, 'modulate:a', 1, 0.3)
	tween.tween_property(left_danger, 'modulate:a', 0, 0.3)
	
	

extends Control
@onready var l_side_core: TextureProgressBar = $"HBoxContainer/LSide Core HP"
@onready var r_side_core: TextureProgressBar = $"HBoxContainer/RSide Core HP"
@onready var player_core: TextureProgressBar = $"HBoxContainer/Player Core HP"
#Emit max hp on ready
@onready var ally_base: Node2D = $"../../../BaseContainer/AllyBase"
@onready var enemy_base_l: Node2D = $"../../../BaseContainer/EnemyBaseL"
@onready var enemy_base_r: Node2D = $"../../../BaseContainer/EnemyBaseR"

@onready var player_hp: TextureProgressBar = $PlayerHP
@onready var player: Player = $"../../../../Player"

func _ready():
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
	else: r_side_core.value = current_hp


func initialize_health_player(max_hp: float,) -> void:
	player_hp.max_value = max_hp

func on_health_changed_player(current_hp: float) -> void:
	player_hp.value = current_hp

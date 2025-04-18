extends Button

@export var upgrade_cost: int = 100
@export var upgrade_id: String = "damage_boost"
@export var icon_sprite: Sprite2D
#@onready var player_stats: PlayerStats = $Stats


func _ready():
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	print("Player has ", PlayerManager.player.stats.gold, " gold")
	if PlayerManager.player.stats.gold >= upgrade_cost:
		PlayerManager.player.stats.gold -= upgrade_cost		
		PlayerManager.player.stats.upgrade_damage(2)		
		print("Purchased:", upgrade_id)
	else:
		print("Not enough gold")

extends Button

@export var upgrade_cost: int = 25
@export var upgrade_value: int = 2
@export var upgrade_id: String = "damage_boost"
@export var icon_path: Texture2D
enum UpgradeType { DAMAGE, MOVEMENT_SPEED, DEFENCE, LUCK }

@export var upgrade_type: UpgradeType = UpgradeType.DAMAGE



func _ready():
	pressed.connect(_on_pressed)
	if icon_path:
		icon = icon_path
	text = str(upgrade_cost) + "g"
func _on_pressed() -> void:
	print("Player has ", PlayerManager.player.stats.gold, " gold")
	if PlayerManager.player.stats.gold >= upgrade_cost:
		PlayerManager.player.stats.gold -= upgrade_cost
		match upgrade_type:
			UpgradeType.DAMAGE:
				PlayerManager.player.stats.upgrade_damage(upgrade_value)
			UpgradeType.MOVEMENT_SPEED:
				PlayerManager.player.stats.upgrade_movement_speed(upgrade_value)
			UpgradeType.DEFENCE:
				PlayerManager.player.stats.upgrade_defence(upgrade_value)
			UpgradeType.LUCK:
				PlayerManager.player.stats.upgrade_luck()

		upgrade_cost = int(round(upgrade_cost * 1.2))
		text = str(upgrade_cost) + "g"
		print("Purchased:", upgrade_type)
	else:
		print("Not enough gold")

extends Control

enum UpgradeType { DAMAGE, MOVEMENT_SPEED, DEFENCE, LUCK, UNITS, SLASH}
@export var upgrade_type: UpgradeType = UpgradeType.DAMAGE
@export var upgrade_id: String = "damage_boost"

@export_category("Costs and Stats")
@export var upgrade_cost: int = 25
@export var upgrade_value: int = 2

## Current level of the item (how many time it was bought)
@export var current_level: int = 0

## Maximum level of the item (how many time it can be bought)
@export var max_level:int = 3

@export_category("Visuals")
@export var icon_path: Texture2D


@export_category("Sounds")
@export var buying_sound:AudioStream
@export var cantbuy_sound:AudioStream
@onready var ui: Control = $"../../../CameraHandler/Camera2D/CanvasLayer/UI"



# limit number of buying
# unit upgrade n amount bought
# slash attack upgrade (x2)

var tween:Tween


func _ready():
	%BuyButton.pressed.connect(_on_pressed)
	%CostLabel.text = str(upgrade_cost)
	%ItemIcon.texture = icon_path
	%LimitLabel.text = str(current_level) + "/" + str(max_level)
	

func _on_pressed() -> void:
	# Not enough gold
	if current_level==max_level:
		play_max_level_reached_animation()
		return
	if PlayerManager.player.stats.gold < upgrade_cost:
		play_not_enough_gold_animation()
		return
	# buy the item
	current_level+=1
	%LimitLabel.text = str(current_level) + "/" + str(max_level)
	PlayerManager.player.stats.gold -= upgrade_cost
	#Adjust the gold in UI
	ui.update_gold(PlayerManager.player.stats.gold)
	play_buying_animation()
	if current_level==max_level:
		self.modulate = Color("717171")
	match upgrade_type:
		UpgradeType.DAMAGE:
			PlayerManager.player.stats.upgrade_damage(upgrade_value)
		UpgradeType.MOVEMENT_SPEED:
			PlayerManager.player.stats.upgrade_movement_speed(upgrade_value)
		UpgradeType.DEFENCE:
			PlayerManager.player.stats.upgrade_defence(upgrade_value)
		UpgradeType.LUCK:
			PlayerManager.player.stats.upgrade_luck()
		
		# TODO: ADD logic for icon switching when units upgrades
		UpgradeType.UNITS:
			PlayerManager.player.stats.upgrade_units()
			PlayerManager.level_upgrades
			#PlayerManager.player.stats.level_upgrades
		
		UpgradeType.SLASH:
			match current_level:
				1: 
					%ItemIcon.texture = load("res://christophe/Shop/Slash2IconShop.png")
					PlayerManager.player.stats.melee_unlocks['spin'] = true
				2: 
					%ItemIcon.texture = load("res://christophe/Shop/Slash3IconShop.png")
					PlayerManager.player.stats.melee_unlocks['slash'] = true
				3:
					PlayerManager.player.stats.melee_unlocks['slash_proj'] = true


	upgrade_cost = int(round(upgrade_cost * 1.2))
	%CostLabel.text = str(upgrade_cost)

	print("Purchased:", upgrade_type)

func play_buying_animation():
	if tween:
		tween.kill()
		%BuyButton.position.x = 0
		self.scale = Vector2(1,1)
	$AudioStreamPlayer2D.stream = buying_sound
	$AudioStreamPlayer2D.play()
	
	self.scale = Vector2(0.8,0.8)
	tween = create_tween()
	tween.tween_property(self,"scale",Vector2(1,1),0.1).set_ease(Tween.EASE_OUT)
	

func play_not_enough_gold_animation():
	if tween:
		tween.kill()
		#%BuyButton.position.x = 0
		self.scale = Vector2(1,1)
	$AudioStreamPlayer2D.stream = cantbuy_sound
	$AudioStreamPlayer2D.play()
	tween = create_tween().set_ease(Tween.EASE_OUT)
	tween.tween_property(%BuyButton,"position:x",0,0.005)
	tween.tween_property(%CostLabel,"modulate",Color("white"),0.005)
	tween.tween_property(%CostLabel,"modulate",Color("ff5454"),0.025)
	tween.tween_property(%BuyButton,"position:x",-2,0.05)
	tween.tween_property(%BuyButton,"position:x",2,0.05)
	tween.tween_property(%BuyButton,"position:x",-2,0.05)
	tween.tween_property(%BuyButton,"position:x",0,0.025)
	tween.tween_property(%CostLabel,"modulate",Color("white"),0.025)

func play_max_level_reached_animation():
	if tween:
		tween.kill()
		#%BuyButton.position.x = 0
		self.scale = Vector2(1,1)
	$AudioStreamPlayer2D.stream = cantbuy_sound
	$AudioStreamPlayer2D.play()
	tween = create_tween().set_ease(Tween.EASE_OUT)
	tween.tween_property(%BuyButton,"position:x",0,0.005)
	tween.tween_property(%LimitLabel,"modulate",Color("white"),0.005)
	tween.tween_property(%LimitLabel,"modulate",Color("ff5454"),0.025)
	tween.tween_property(%BuyButton,"position:x",-2,0.05)
	tween.tween_property(%BuyButton,"position:x",2,0.05)
	tween.tween_property(%BuyButton,"position:x",-2,0.05)
	tween.tween_property(%BuyButton,"position:x",0,0.025)
	tween.tween_property(%LimitLabel,"modulate",Color("white"),0.025)

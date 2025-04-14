extends Area2D

@export var sprite : Sprite2D
@export var spell: Spell


func _ready() -> void:
	body_entered.connect(on_body_entered)
	#sprite.texture = 
	#Price
	
	
func on_body_entered(body: Node) -> void:
	#print("Upgrade has ", body, " entered")
	if body.is_in_group("player"):
		print("Body is in player group")
		PlayerStats.add_upgrade(spell)
		queue_free()

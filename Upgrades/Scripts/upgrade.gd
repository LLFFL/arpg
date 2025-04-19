extends Area2D

@export var texture: Texture2D
@export var pickup: Pickup


func _ready() -> void:
	$Sprite2D.texture = texture
	body_entered.connect(on_body_entered)
	#sprite.texture = 
	#Price
	
	
func on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		if pickup.is_passive:
			PlayerManager.player.stats.add_passive(pickup)
		else:
			PlayerManager.player.stats.add_upgrade(pickup)
		queue_free()

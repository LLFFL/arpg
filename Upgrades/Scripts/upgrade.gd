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
		print("Picked up: ", pickup)

		if pickup.is_passive:
			PlayerStats.add_passive(pickup)
		else:
			PlayerStats.add_upgrade(pickup)

		queue_free()

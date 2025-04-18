extends ProgressBar
@onready var player: Player = $"../../Player"

func _ready():
	set_max(player.max_hp)
	

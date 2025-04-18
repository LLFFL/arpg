extends ProgressBar



func _process(_delta):
	value = PlayerManager.player.stats.health
	max_value = PlayerManager.player.stats.max_health

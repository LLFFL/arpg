extends Node2D


func _ready():
	
	for child in $HBoxContainer.get_children():
		$HBoxContainer.move_child(child,randi_range(0,5))

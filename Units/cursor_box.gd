extends Area2D

@export var leechCursor: = preload("res://Screenshot 2025-04-20 124328.jpg")
@export var defaultCursor: Texture

	
func _ready():	
	#if get_parent().is_in_group("allied_base"):
		mouse_entered.connect(_on_mouse_entered)
		mouse_exited.connect(_on_mouse_exited)
	
func _on_mouse_entered():
	print("mouse_entered")
	Input.set_custom_mouse_cursor(leechCursor)

func _on_mouse_exited():
	Input.set_custom_mouse_cursor(defaultCursor)

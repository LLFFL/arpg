extends Node2D

var time  = 0.00
func _process(delta):
	self.position.x = cos(deg_to_rad(time))*10
	self.position.y = -5 + sin(deg_to_rad(time))*2.5
	time+=500*delta


#func _ready():
	#var t = create_tween().set_loops()
	#t.tween_property(self,"position:x",-self.position.x,1).set_trans(Tween.TRANS_QUAD)
	#t.tween_property(self,"position:y",position.y+1,0.1).set_trans(Tween.TRANS_QUAD)
	#t.tween_property(self,"position:x",self.position.x,1).set_trans(Tween.TRANS_QUAD)
	#t.tween_property(self,"position:y",position.y-1,0.1).set_trans(Tween.TRANS_QUAD)
	#t.tween_property(self,"rotation_degrees",360,2)
	#t.tween_property(self,"rotation_degrees",0,2)

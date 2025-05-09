extends Node2D

## This little map is to showcase the world setup
## The player sprite2D.use_parent_material should be set to true
## And the player instance in this scene uses a material that adds an outline

const MENU = preload("res://christophe/Menu/menu.tscn")
@export var player:Player
@export var mountains_gradient:Gradient
@export var sky_gradient:Gradient
@export_category("Clouds")
@export var cloud_shadow:Gradient
@export var cloud_base:Gradient
@export var cloud_highlight:Gradient
@onready var left_start_bound: StaticBody2D = $LeftStartBound
@onready var right_start_bound: StaticBody2D = $RightStartBound
@onready var portal_arrow: Sprite2D = $PortalArrow
@onready var respawn_marker: Marker2D = $RespawnMarker
@onready var ui: Control = $CameraHandler/Camera2D/CanvasLayer/UI
@onready var portal_audio_player: AudioStreamPlayer2D = $Map/Portal/PortalAudioPlayer
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


@export var OpenPortalSound:AudioStream
@export var ClosePortalSound:AudioStream

var game_started: bool = false
var _game_started: bool = false
var game_time: float = 0

## True if the player portal is open
var portal_is_open = false

## Tween used to close and open the portal. Whenever either happens, 
## the tween is killed and recreated. That way, the open/close anim never overlaps
var portal_tween:Tween

@onready var base_container: Node = %BaseContainer
var bases_dictionary: Dictionary
func _ready():
	
	PlayerManager.game_won = false
	PlayerManager.game_started = true
	$CameraHandler/Camera2D/ShakerComponent2D.intensity = float(Options.screen_shake_enabled)
	PlayerManager.player.player_died.connect(_on_player_death)
	var bases = base_container.get_children()
	for base in bases:
		base.game_ended.connect(end_game)
	bases_dictionary = {
		'ally_base' = bases[0],
		'enemy_base_L' = bases[1],
		'enemy_base_R' = bases[2]
	}	# it is order of scene structure descending from top to down so [ally, right base, left base] in the array
	give_bases_dictionary()	
	#hide the shop ui
	%ShopUi.modulate.a = 0
	$CameraHandler/Camera2D/ShakerComponent2D.intensity = Options.screen_shake_intensity
	
func give_bases_dictionary():
	$BaseContainer/AllyBase.initialize(bases_dictionary)
	$BaseContainer/EnemyBaseL.initialize(bases_dictionary)
	$BaseContainer/EnemyBaseR.initialize(bases_dictionary)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_game"):
		var menu = MENU.instantiate()
		%MinionSideControl.hide()
		player.player_hp_ui.hide()
		%ShopUi.hide()
		%Portal.hide()
		get_tree().root.add_child(menu)
		menu.bg_2.hide()
		player.visible = false
		$CameraHandler/Camera2D.enabled = false
		ui.hide()
		self.process_mode = Node.PROCESS_MODE_DISABLED

func _process(delta):
	if _game_started:
		game_time += delta
	## Player position remapped to [0.0, 1.0] where 0 is ice and 1 is fire
	var player_mapped_position:float = remap(player.global_position.x, -1200, 1200, 0, 1)
	
	# Set the background color of elements based on the player positions
	%MontainsSprite.modulate = mountains_gradient.sample(player_mapped_position)
	%SkyRect.color = sky_gradient.sample(player_mapped_position)
	$Map/CLOUDS/CloudSprite.material.set("shader_parameter/shadow",cloud_shadow.sample(player_mapped_position))
	$Map/CLOUDS/CloudSprite.material.set("shader_parameter/base",cloud_base.sample(player_mapped_position))
	$Map/CLOUDS/CloudSprite.material.set("shader_parameter/highlight",cloud_highlight.sample(player_mapped_position))
	# Emits particles only when player is near the ice / fire side
	if player_mapped_position<=0.3:
		$Map/SnowParticles.emitting = true
		#$PortalArrow.hide()
		%Portal.hide()
	elif player_mapped_position>=0.7:
		$Map/FireParticles.emitting = true
		%Portal.hide()
		#$PortalArrow.hide()
	# Poor and lazy optimisation in case
	else:
		#$PortalArrow.show()
		%Portal.show()
		#$PortalArrow.modulate.a = remap(player.)
	#$PortalArrow.look_at(%Portal.global_position)
	#$PortalArrow.global_rotation = lerp_angle($PortalArrow.global_rotation,(%Portal.global_position - player.global_position).angle(),0.02) 

		
	
	# Quick n dirty way to check if the player is in or out the portal
	#if !portal_is_open and player.global_position.distance_to(%Portal.global_position+Vector2(0,30))<=80:
		#$PortalArrow.show()
	if !portal_is_open and player.global_position.distance_to(%Portal.global_position+Vector2(0,30))<=50:
		open_portal()
	if portal_is_open and  player.global_position.distance_to(%Portal.global_position)>100:
		close_portal()
	
#func _input(event):
	#if event.is_action_pressed("ui_select") :
#		$SnowCore.play_hit_animation()
#		$FireCore.play_hit_animation()


## Open the Portal and show shop ui
func open_portal():
	#if !game_started:
		#game_started = true
		#var timer: Timer = Timer.new()
		#timer.wait_time = 3
		#timer.timeout.connect(func(): 
			#
			#timer.queue_free())
		#add_child(timer)
		#timer.start()
	if portal_is_open:return
	if portal_tween:
		portal_tween.kill()
	
	portal_is_open = true
	portal_audio_player.stream = OpenPortalSound
	portal_audio_player.play()
	player.get_node("Sprite2D").material.set("shader_parameter/line_color",Color("1fe2a2"))
	# Animate the scale and visibility of stuff when opening
	portal_tween = create_tween()
	portal_tween.parallel().tween_property(player.get_node("Sprite2D").material,"shader_parameter/line_thickness",1,0.2)
	portal_tween.parallel().tween_property(player.get_node("shadow"),"modulate:a",0,0.2)
	portal_tween.parallel().tween_property(%Portal,"scale",Vector2(5,5),0.8)
	portal_tween.parallel().tween_property(%Portal/Interior,"scale",Vector2(0.2,0.2),0.8)
	portal_tween.parallel().tween_property(%Frog,"position",Vector2(-120,110),1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(0.2)
	portal_tween.parallel().tween_property(%ShopUi,"modulate:a",1,0.1).set_delay(0.4)
	player.z_index = 5
	await portal_tween
	%Portal.z_index = 3
	%ShopUi.process_mode = Node.PROCESS_MODE_INHERIT

	
## Close the Portal and hide shop ui
func close_portal():
	if !game_started:
		game_started = true
		start_game()
	if !portal_is_open:return
	portal_is_open = false
	portal_audio_player.stream = ClosePortalSound
	portal_audio_player.play()
	if portal_tween:
		portal_tween.kill()
	# Animate the portal closing and hide stuff
	%ShopUi.process_mode = Node.PROCESS_MODE_DISABLED
	portal_tween = create_tween()
	portal_tween.tween_property(%Portal,"scale",Vector2(1,1),2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	portal_tween.parallel().tween_property(player.get_node("shadow"),"modulate:a",0.5,0.2)
	portal_tween.parallel().tween_property(%Portal/Interior,"scale",Vector2(1,1),2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	portal_tween.parallel().tween_property(%ShopUi,"modulate:a",0,0.5)
	portal_tween.parallel().tween_property(player.get_node("Sprite2D").material,"shader_parameter/line_thickness",0,0.2)
	portal_tween.tween_property(%Frog,"position",Vector2(-65,50),0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	player.z_index = 0
	%Portal.z_index = -1

func start_game():
	_game_started = true
	left_start_bound.queue_free()
	right_start_bound.queue_free()
	var tween = create_tween()
	tween.tween_property(portal_arrow, 'modulate:a', 0, 2 )
	#tween.tween_property($Sprite, "scale", Vector2(), 1)
	tween.tween_callback(func():
		portal_arrow.queue_free()
		tween.kill())
	bases_dictionary.ally_base._on_game_start()
	bases_dictionary.enemy_base_L._on_game_start()
	bases_dictionary.enemy_base_R._on_game_start()
	ui.flash_danger()
	pass

func end_game(win: bool):
	game_started = false
	PlayerManager.game_started = false
	PlayerManager.current_time = game_time
	if win:
		if game_time > 0:
			PlayerManager.game_times.append(game_time)
			PlayerManager.game_times.sort()
			if PlayerManager.game_times.size() > 5:
				PlayerManager.game_times.pop_back()
		PlayerManager.game_won = true
	else:
		PlayerManager.game_won = false
	PlayerManager.player = null
	get_tree().change_scene_to_file("res://christophe/EndScreen/end_screen.tscn")

func _on_player_death():
	PlayerManager.player.global_position = respawn_marker.global_position
	PlayerManager.player.stats.health = PlayerManager.player.stats.max_health
	PlayerManager.player.stats.stun_entity(2)
	ui.on_health_changed_player(PlayerManager.player.stats.health)
	pass

func resume():
	$CameraHandler/Camera2D.enabled = true
	$CameraHandler/Camera2D/ShakerComponent2D.intensity = float(Options.screen_shake_enabled)
	player.player_hp_ui.show()
	%ShopUi.show()
	%Portal.show()
	player.visible = true
	ui.show()
	%MinionSideControl.show()
	self.process_mode = Node.PROCESS_MODE_INHERIT

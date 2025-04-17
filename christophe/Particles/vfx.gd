extends Node2D
class_name vfx
## Visual effects

@export var color:Color = Color("white")
@export var free_when_finished = true
## the vfx became visible and is playing
signal started

## the vfx is done playing and is not visible anymore
signal finished

## true when the vfx is currently stopping itself roughly by [force_stop()]
var is_forced_stopping = false

var _particles_initial_state = {}
var _tween:Tween

var _playable_children_count = 0

func _ready():
	for child in get_children():
		if child is CPUParticles2D:
			_particles_initial_state[child] = child.one_shot
			child.finished.connect(_child_finished)

## configure the vfx based on its parent
func setup():
	is_forced_stopping = false
	_playable_children_count = 0
	self.modulate = color
	if free_when_finished:
		finished.connect(queue_free)

	for child in get_children():
		if child is CPUParticles2D:
			
			child.emitting = false
			child.restart()
			if _particles_initial_state.has(child):
				print(child)
				child.one_shot = _particles_initial_state[child]

## Starts the vfx (display and show visuals)
## if [code]duration[/code] is greater than 0, stops this vfx after 
## [code]duration[/code] seconds. Some VFX ends by themselves
func start(duration=0):
	for child in get_children():
		child.show()
		if child is CPUParticles2D:
			_playable_children_count+=1
			child.restart()
			child.emitting = true
			#connect("",print,)

			#child.finished
	if duration>0:
		await get_tree().create_timer(duration).timeout
		stop()
		
## Gradually stops the vfx
## if [code]limit_time[/code] is greater than 0, force stops this vfx after 
## [code]limit_time[/code] seconds
func stop(limit_time=0.0):
	for child in get_children():
		if child is CPUParticles2D:
			child.one_shot = true
	if limit_time>0.0:
		await get_tree().create_timer(limit_time).timeout
		self.force_stop()
		

## Stops the vfx smoothly but really really fast
## see [stop()] for something smoother
func force_stop():
	# dont let this be called twice
	if is_forced_stopping : return
	is_forced_stopping = true
	var t = create_tween()
	t.tween_property(self,"modulate:a",0,0.1)
	for child in get_children():
		if is_instance_valid(child):
			if child is CPUParticles2D:
				child.emitting = false
	await t.finished
	finished.emit()


## Called whenever a child has finished playing
## If no other child are still playing, this vfx is ready to be stopped
func _child_finished():
	_playable_children_count-=1
	if _playable_children_count<=0:
		# Emit a signal but only if this vfx isnt being forced to disapear
		if !is_forced_stopping:
			finished.emit()


# setup
# signals

# Spawning
# Despawning

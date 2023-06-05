extends Node2D

@onready var ladle = get_node("../ladle")

var levelScales = [0.7, 2, 3.4, 4.7]
var stateImages = [
	load("res://Assets/Soup/pixil-layer-4.png"), 
	load("res://Assets/Soup/pixil-layer-3.png"), 
	load("res://Assets/Soup/pixil-layer-2.png"), 
	load("res://Assets/Soup/pixil-layer-1.png")]
 
var levelupdate
var stateupdate
@export var level = Globals.cauldronLevels.EMPTY
@export var state = Globals.cauldronState.PRETTYGOOD

# Called when the node enters the scene tree for the first time.
func _ready():
	$soup.scale = Vector2(levelScales[level],levelScales[level])
	$tempSoup.scale = Vector2(levelScales[level],levelScales[level])
	$soup.texture = stateImages[state]
	$tempSoup.texture = stateImages[state]
	Globals.SOUPSTATS.umami = state
	Globals.soupLevel = level
	$AudioStreamPlayer2D.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if levelupdate:
		var vec = Vector2(levelScales[level], levelScales[level])
		$soup.scale = $soup.scale.lerp(vec, delta)
		$tempSoup.scale = $tempSoup.scale.lerp(vec, delta)
		if $soup.scale == vec:
			levelupdate = false
	if stateupdate:
		state = Globals.SOUPSTATS.umami
		$tempSoup.texture = stateImages[state]
		$tempSoup.visible = true
		$AnimationPlayer.play("crossfade")
		stateupdate = false

func _on_cauldron_area_area_entered(area):
	if (area.name == "SpoonPart"):
		ladle.pourable = true

func _on_cauldron_area_area_exited(area):
	if (area.name == "SpoonPart"):
		ladle.pourable = false

func _changeCrossfadeSprite():
	$soup.texture = stateImages[state]
	$soup.self_modulate = Color(1, 1, 1, 1)
	$tempSoup.self_modulate = Color(1, 1, 1, 0)

func updateLevel(nr):
	level += nr
	if level < Globals.cauldronLevels.EMPTY: level = Globals.cauldronLevels.EMPTY
	elif level > Globals.cauldronLevels.FULL: level = Globals.cauldronLevels.FULL
	Globals.soupLevel = level
	levelupdate = true 
	if level == Globals.cauldronLevels.EMPTY: Globals.degradeSoupItems(99)
	elif nr < 0: Globals.degradeSoupItems(10)
	elif nr > 0: Globals.degradeSoupItems(20)


func _on_audio_stream_player_2d_finished():
	$AudioStreamPlayer2D.play()

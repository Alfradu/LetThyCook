extends Node2D

@onready var ladle = get_node("../ladle")

enum cauldronLevels { EMPTY = 0, ALMOSTEMPTY = 1, PRETTYFULL = 2, FULL = 3} 
var levelScales = [0.7, 2, 3.4, 4.7]
enum cauldronState { UNEATABLE = 0, BAD = 1, PRETTYGOOD = 2, AMAZING = 3}
var stateImages = [
	load("res://Assets/Soup/pixil-layer-4.png"), 
	load("res://Assets/Soup/pixil-layer-3.png"), 
	load("res://Assets/Soup/pixil-layer-2.png"), 
	load("res://Assets/Soup/pixil-layer-1.png")]
 
var levelupdate
var stateupdate
@export var level = cauldronLevels.EMPTY
@export var state = cauldronState.PRETTYGOOD

# Called when the node enters the scene tree for the first time.
func _ready():
	$soup.scale = Vector2(levelScales[level],levelScales[level])
	$tempSoup.scale = Vector2(levelScales[level],levelScales[level])
	$soup.texture = stateImages[state]
	$tempSoup.texture = stateImages[state]
	Globals.soupState = state
	Globals.soupLevel = level

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if levelupdate:
		var vec = Vector2(levelScales[level], levelScales[level])
		$soup.scale = $soup.scale.lerp(vec, delta)
		$tempSoup.scale = $tempSoup.scale.lerp(vec, delta)
		if $soup.scale == vec:
			levelupdate = false
	if stateupdate:
		state = Globals.soupState
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

func poured():
	if level != cauldronLevels.FULL:
		level = level+1 as cauldronLevels
		levelupdate = true

func _changeCrossfadeSprite():
	$soup.texture = stateImages[state]
	$soup.self_modulate = Color(1, 1, 1, 1)
	$tempSoup.self_modulate = Color(1, 1, 1, 0)

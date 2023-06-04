extends Node2D

@onready var ladle = get_node("../ladle")

enum cauldronLevels { EMPTY = 0, ALMOSTEMPTY = 1, PRETTYFULL = 2, FULL = 3} 
var levelScales = [0.7, 2, 3.4, 4.7]
enum cauldronState { UNEATABLE = 0, BAD = 1, PRETTYGOOD = 2, AMAZING = 3}
var stateImages = ["res://Assets/Soup/pixil-layer-4.png", "res://Assets/Soup/pixil-layer-3.png", "res://Assets/Soup/pixil-layer-2.png", "res://Assets/Soup/pixil-layer-1.png"]
 
var update
@export var level = cauldronLevels.EMPTY
@export var state = cauldronState.PRETTYGOOD

# Called when the node enters the scene tree for the first time.
func _ready():
	$soup.scale = Vector2(levelScales[level],levelScales[level])
	$soup.texture = load(stateImages[state])
	Globals.soupState = state
	Globals.soupLevel = level

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if update:
		var vec = Vector2(levelScales[level], levelScales[level])
		$soup.scale = $soup.scale.lerp(vec, delta)
		if $soup.scale == vec:
			update = false

func _on_cauldron_area_area_entered(area):
	if (area.name == "SpoonPart"):
		ladle.pourable = true

func _on_cauldron_area_area_exited(area):
	if (area.name == "SpoonPart"):
		ladle.pourable = false

func poured():
	if level != cauldronLevels.FULL:
		level = level+1
		update = true

extends Node2D

@onready var ladle = get_node("../ladle")

enum cauldronLevels { EMPTY = 0, ALMOSTEMPTY = 1, PRETTYFULL = 2, FULL = 3} 
var levelScales = [0.7, 2, 3.4, 4.7]
@export var level = cauldronLevels.EMPTY
var update
# Called when the node enters the scene tree for the first time.
func _ready():
	$soup.scale = Vector2(levelScales[level],levelScales[level])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if update:
		var vec = Vector2(levelScales[level], levelScales[level])
		$soup.scale = $soup.scale.lerp(vec, delta)
		if $soup.scale == vec:
			update = false

func _on_cauldron_area_area_entered(area):
	print(area.name)
	if (area.name == "SpoonPart"):
		ladle.pourable = true

func _on_cauldron_area_area_exited(area):
	if (area.name == "SpoonPart"):
		ladle.pourable = false

func poured():
	if level != cauldronLevels.FULL:
		level = level+1
		update = true

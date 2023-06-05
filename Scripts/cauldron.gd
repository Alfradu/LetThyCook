extends Node2D

@onready var ladle = get_node("../ladle")
@onready var bubble = load("res://Scenes/bubble.tscn")

var levelScales = [0.7, 2, 3.4, 4.7]
var stateImages = [
	load("res://Assets/Soup/pixil-layer-4.png"), 
	load("res://Assets/Soup/pixil-layer-3.png"), 
	load("res://Assets/Soup/pixil-layer-2.png"), 
	load("res://Assets/Soup/pixil-layer-1.png")]
 
var rng = RandomNumberGenerator.new()

var levelupdate
var stateupdate
var soundLevel
var isChangingSound
var timeSinceBubble = 0
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
	$AudioStreamPlayer2D.volume_db = level * (level + 1)
	$AudioStreamPlayer2D.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if levelupdate:
		var vec = Vector2(levelScales[level], levelScales[level])
		$soup.scale = $soup.scale.lerp(vec, delta)
		$soupStatic.scale = $soupStatic.scale.lerp(vec, delta)
		$tempSoup.scale = $tempSoup.scale.lerp(vec, delta)
		if $soup.scale == vec:
			levelupdate = false
	if stateupdate:
		state = Globals.SOUPSTATS.umami
		$tempSoup.texture = stateImages[state]
		$tempSoup.visible = true
		$AnimationPlayer.play("crossfade")
		stateupdate = false
	if isChangingSound:
		var diff = $AudioStreamPlayer2D.volume_db - soundLevel
		var up = diff < 0
		if up:
			$AudioStreamPlayer2D.volume_db += -diff if diff < 1 && diff > -1 else 1
		else:
			$AudioStreamPlayer2D.volume_db += diff if diff < 1 else -1
		if $AudioStreamPlayer2D.volume_db == soundLevel:
			isChangingSound = false
	timeSinceBubble += delta
	if level != Globals.cauldronLevels.EMPTY && timeSinceBubble > 3.5 - state:
		spawnBubble()
		timeSinceBubble = 0

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
	changeSound(level)
	levelupdate = true 
	if level == Globals.cauldronLevels.EMPTY: Globals.degradeSoupItems(99)
	elif nr < 0: Globals.degradeSoupItems(10)
	elif nr > 0: Globals.degradeSoupItems(20)

func changeSound(level):
	soundLevel = level * (level + 1) if level * (level + 1) != 0 else -80
	isChangingSound = true	

func spawnBubble():
	var bubblespawn = bubble.instantiate()
	var r = rng.randf_range(5, $soupStatic.scale.x * 10)
	var angle = rng.randf_range(0, 180)
	var x = r * cos(angle)
	var y = r * sin(angle) - $soupStatic.scale.x * 12
	bubblespawn.position = Vector2(x, y)
	bubblespawn.rotation = 0
	$soupStatic.add_child(bubblespawn)

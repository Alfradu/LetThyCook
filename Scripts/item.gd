extends Node2D

@onready var sprite = $Sprite2D
@onready var shadow = $Sprite2D/shadow
@onready var hand = get_node("/root/Main/hand")
@onready var toolTip = load("res://Scenes/toolTip.tscn")
@onready var VeggieSpawn = $/root/Main/tableLeft/SpawnAreaVeggies
@onready var HerbSpawn = $/root/Main/tableRight/SpawnAreaHerbs
@onready var ProteinSpawn = $/root/Main/tableMid/SpawnAreaProtein


var foodItem
var dragging = false
var overCauldron = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func init(item):
	var rng = RandomNumberGenerator.new()
	var texture = load(Globals.getTexture(item.name))
	sprite.texture = texture
	shadow.texture = texture
	var spawn
	match item.type:
		Globals.FoodType.PROTEIN:
			spawn = [ProteinSpawn.global_position, ProteinSpawn.get_rect().size*ProteinSpawn.scale]
		Globals.FoodType.HERB:
			spawn = [HerbSpawn.global_position, HerbSpawn.get_rect().size*HerbSpawn.scale]
		Globals.FoodType.VEGETABLE, _:
			spawn = [VeggieSpawn.global_position, VeggieSpawn.get_rect().size*VeggieSpawn.scale]
	self.position = Vector2(rng.randf_range(spawn[0].x,spawn[0].x+spawn[1].x), rng.randf_range(spawn[0].y, spawn[0].y+spawn[1].y))
#	var randRotation = rng.randf_range(0,360)
#	sprite.rotation = randRotation messes up shadow xd
	foodItem = item

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if dragging:
		var mousepos = get_viewport().get_mouse_position()
		self.position = Vector2(mousepos.x, mousepos.y)

func _input(event):
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && !$AnimationPlayer.is_playing() && !Globals.bookOpen:
		if event.is_pressed() && hand.pickedItem == self && !Globals.bookOpen: 
			dragging = true;
			$gotGrabbed.play()
		elif hand.state == Globals.handState.OPEN && !Globals.bookOpen:
			dragging = false;
			if overCauldron:
				$AnimationPlayer.play("plums");

func _on_area_2d_area_entered(area):
	if area.name == "HandCollision" && !Globals.bookOpen:
		hand.pickedItem = self
		if !overCauldron:
			hand.setText(foodItem.name if foodItem != null else "")
	if area.name == "cauldronArea":
		overCauldron = true;

func _on_area_2d_area_exited(area):
	if area.name == "cauldronArea":
		overCauldron = false;
	if area.name == "HandCollision":
		if hand.pickedItem == self:
			hand.pickedItem = null
		hand.clearText(foodItem.name if foodItem != null else "")

func _souped():
	#add stats n point to soup
	self.visible = false
	$gotSplashed.play()
	spawnToolTip()

func _on_got_splashed_finished():
	queue_free();

func spawnToolTip():
	var instantiateditem = toolTip.instantiate()
	$/root/Main/cauldron/ItemToolTips.add_child(instantiateditem)
	instantiateditem.init(foodItem, load(Globals.getTexture(foodItem.name)))

func _plums():
	if Globals.soupLevel > 1:
		$plums.visible = true
		$plums/AnimationPlayer.play("splash")
	foodItem.inSoup = true
	Globals.Score += foodItem.ttl
	Globals.calculateSoup()

extends Node2D

@onready var sprite = $Sprite2D
@onready var hand = get_node("/root/Main/hand")

var foodItem
var dragging = false
var overCauldron = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func init(item):
	var rng = RandomNumberGenerator.new()
	var texture = load(getTexture(item.name))
	sprite.texture = texture
	self.position.x = rng.randf_range(50, 300)
	self.position.y = rng.randf_range(300, 1000)
	$Sprite2D.rotation = rng.randf_range(0,360)
	foodItem = item
	
func getTexture(itemname):
	return "res://Assets/Soup/items/" + itemname.to_lower() + "1.png"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if dragging:
		var mousepos = get_viewport().get_mouse_position()
		self.position = Vector2(mousepos.x, mousepos.y)

func _input(event):
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && !$AnimationPlayer.is_playing():
		if event.is_pressed() && hand.pickedItem == self: 
			dragging = true;
		elif hand.state == Globals.handState.OPEN:
			dragging = false;
			if overCauldron:
				$AnimationPlayer.play("plums");

func _on_area_2d_area_entered(area):
	if area.name == "HandCollision":
		hand.pickedItem = self
	if area.name == "cauldronArea":
		overCauldron = true;

func _on_area_2d_area_exited(area):
	if area.name == "cauldronArea":
		overCauldron = false;

func _souped():
	#add stats n point to soup
	self.visible = false
	queue_free();

func _plums():
	if Globals.soupLevel > 1:
		$plums.visible = true
		$plums/AnimationPlayer.play("splash")
	foodItem.inSoup = true

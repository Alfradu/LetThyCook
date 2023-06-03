extends Node2D

enum ItemType { NONE, CABBAGE, CARROT, POTATO}
var sprite_cabbage1 = load("res://Assets/Soup/Cabbage/cabbage1.png")
var sprite_potato1 = load("res://Assets/Soup/Potato/potato1.png")
var sprite_potato2 = load("res://Assets/Soup/Potato/potato2.png")
var sprite_potato3 = load("res://Assets/Soup/Potato/potato3.png")
var sprite_carrot1 = load("res://Assets/Soup/Carrot/carrot1.png")
var sprite_carrot2 = load("res://Assets/Soup/Carrot/carrot2.png")
var sprite_carrot3 = load("res://Assets/Soup/Carrot/carrot3.png")

@export var type = ItemType.NONE
@onready var sprite = $Sprite2D
@onready var hand = get_node("../hand")

var dragging = false
var overCauldron = false
# Called when the node enters the scene tree for the first time.
func _ready():
	if type==ItemType.CABBAGE:
		sprite.texture = sprite_cabbage1
	elif type == ItemType.CARROT:
		sprite.texture = sprite_carrot1
	elif type == ItemType.POTATO:
		sprite.texture = sprite_potato1
	else : queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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


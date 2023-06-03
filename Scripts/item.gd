extends Node2D

enum ItemType { NONE, CABBAGE, CARROT, POTATO}
var sprite_cabbage1 = load("res://Assets/Soup/Cabbage/cabbage1.png")
var sprite_potato1 = load("res://Assets/Soup/Potato/potato1.png")
var sprite_potato2 = load("res://Assets/Soup/Potato/potato2.png")
var sprite_potato3 = load("res://Assets/Soup/Potato/potato3.png")
var sprite_carrot1 = load("res://Assets/Soup/Carrot/carrot1.png")
var sprite_carrot2 = load("res://Assets/Soup/Carrot/carrot2.png")
var sprite_carrot3 = load("res://Assets/Soup/Carrot/carrot3.png")

@export var type =  ItemType.NONE
@onready var sprite = $Sprite2D

var hovering = false
var dragging = false
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

"""
func _input(event):
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT:
		print(event.as_text())
		if event.is_pressed() && hovering: 
			dragging = true;
		elif hovering:
			dragging = false; 
"""
func _input_event(viewport, event, shape_idx):
	print(event.as_text())
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed(): 
			dragging = true;
		else:
			dragging = false;

func _on_static_body_2d_mouse_entered():
	print("TEST")
	hovering = true

func _on_static_body_2d_mouse_exited():
	hovering = false


func _on_area_2d_mouse_entered():
	pass # Replace with function body.

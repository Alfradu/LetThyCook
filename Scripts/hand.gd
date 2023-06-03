extends Node2D

@onready var sprite = $Sprite2D
var sprite_open = load("res://Assets/hand/hand-open.png")
var sprite_closed = load("res://Assets/hand/hand-closed.png")

enum handState { OPEN, CLOSED}
var state = handState.OPEN
var pickedItem

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mousepos = get_viewport().get_mouse_position()
	self.position = Vector2(mousepos.x, mousepos.y)
	
func _input(event):
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed() && state == handState.OPEN: 
			sprite.texture = sprite_closed
			state = handState.CLOSED
		elif state == handState.CLOSED:
			sprite.texture = sprite_open
			state = handState.OPEN

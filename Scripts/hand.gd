extends Node2D

@onready var sprite = $Sprite2D

var sprite_open = load("res://Assets/hand/hand-open.png")
var sprite_closed = load("res://Assets/hand/hand-closed.png")

var state = Globals.handState.OPEN
var pickedItem

# Called when the node enters the scene tree for the first time.
func _ready():
	$HoverText.text = ""

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var mousepos = get_viewport().get_mouse_position()
	self.position = Vector2(mousepos.x, mousepos.y)
	
func _input(event):
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed() && state == Globals.handState.OPEN: 
			sprite.texture = sprite_closed
			state = Globals.handState.CLOSED
		elif state == Globals.handState.CLOSED:
			sprite.texture = sprite_open
			state = Globals.handState.OPEN
			pickedItem = null

func setText(text):
	if state != Globals.handState.CLOSED:
		$HoverText.text = text
	
func clearText(text):
	if $HoverText.text == text: 
		$HoverText.text = ""

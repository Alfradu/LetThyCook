extends Node2D

@onready var sprite = $handhand
@onready var arm = $armhand

var sprite_open = load("res://Assets/hand/hand-open.png")
var sprite_closed = load("res://Assets/hand/hand-closed.png")

var state = Globals.handState.OPEN
var pickedItem
var expansion = 0
var armScaleY
var armScaleX
var armY
# Called when the node enters the scene tree for the first time.
func _ready():
	armScaleY = arm.scale.y
	armScaleX = arm.scale.x
	armY = arm.position.y
	$HoverText.text = ""

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var mousepos = get_viewport().get_mouse_position()
	var viewportRect = get_viewport().get_visible_rect()
	if mousepos.x < viewportRect.size.x && mousepos.x > 0 && mousepos.y < viewportRect.size.y && mousepos.y > 0:
		self.position = Vector2(mousepos.x, mousepos.y)
		if viewportRect.size.y-mousepos.y > 700:
			expansion = (viewportRect.size.y-mousepos.y-700)/1000
		else:
			expansion = 0
		arm.scale.y = armScaleY + expansion * 4
		arm.scale.x = armScaleX - expansion
		arm.position.y = armY + expansion * 1000
	
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

extends Node2D

@onready var sprite = $handhand
@onready var arm = $armhand
@onready var arm2 = $point/armhand2

var sprite_open = load("res://Assets/hand/hand-open.png")
var sprite_closed = load("res://Assets/hand/hand-closed.png")

var state = Globals.handState.OPEN
var pickedItem
var expansion = 0
var armScaleY
var armScaleX
var armPointScaleY
var armPointScaleX
var armY
var armYpoint

var pointing = false

# Called when the node enters the scene tree for the first time.
func _ready():
	point()
	armScaleY = arm.scale.y
	armScaleX = arm.scale.x
	armPointScaleY = arm2.scale.y
	armPointScaleX = arm2.scale.x
	armY = arm.position.y
	armYpoint = arm2.position.y
	$HoverText.text = ""

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var mousepos = get_viewport().get_mouse_position()
	var viewportRect = get_viewport().get_visible_rect()
	if !pointing:
		if mousepos.x < viewportRect.size.x && mousepos.x > 0 && mousepos.y < viewportRect.size.y && mousepos.y > 0:
			self.position = Vector2(mousepos.x, mousepos.y)
			if viewportRect.size.y-mousepos.y > 700:
				expansion = (viewportRect.size.y-mousepos.y-700)/1000
			else:
				expansion = 0
			arm.scale.y = armScaleY + expansion * 4
			arm.scale.x = armScaleX - expansion
			arm.position.y = armY + expansion * 1000
	else:
		if mousepos.x < viewportRect.size.x && mousepos.x > 0 && mousepos.y < viewportRect.size.y && mousepos.y > 0:
			self.position = Vector2(mousepos.x, mousepos.y)
			if viewportRect.size.y-mousepos.y > 700:
				expansion = (viewportRect.size.y-mousepos.y-700)/1000
			else:
				expansion = 0
			arm2.scale.y = armPointScaleY + expansion * 4
			arm2.scale.x = armPointScaleX - expansion
			arm2.position.y = armYpoint + expansion * 1000
	
func _input(event):
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && !pointing:
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

func point():
	pointing = true
	pickedItem = null
	$wrist.visible = false
	$armhand.visible = false
	$handhand.visible = false
	$point.visible = true
	
func grab():
	pointing = false
	pickedItem = null
	$wrist.visible = true
	$armhand.visible = true
	$handhand.visible = true
	$point.visible = false

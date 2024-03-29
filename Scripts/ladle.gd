extends Node2D

enum ActionType { EMPTY, FULL, POURING }
var ladle_full = load("res://Assets/Barrel/ladle_full.png")
var ladle_empty = load("res://Assets/Barrel/ladle.png")
var ladle_pouring = load("res://Assets/Barrel/ladle_pouring.png")

@onready var hand = get_node("../hand")
@onready var startingPos = self.position
@onready var sprite = $Ladle
var state = ActionType.EMPTY
var onBarrel = false
var dragging = false
var pourable = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if state == ActionType.EMPTY && onBarrel && dragging:
		state = ActionType.FULL
		sprite.texture = ladle_full
	
	if state == ActionType.POURING:
		if (!$AnimationPlayer.is_playing()):
			sprite.texture = ladle_pouring
			$AnimationPlayer.play("pour")
			Globals.updateCauldronLevel(1)
			Globals.calculateSoup()
		return
	
	if dragging:
		var mousepos = get_viewport().get_mouse_position()
		self.position = Vector2(mousepos.x, mousepos.y)
	else:
		self.position = self.position.lerp(startingPos, delta)
	
func _input(event):
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && !Globals.bookOpen:
		if event.is_pressed() && hand.pickedItem == self: 
			dragging = true;
		elif hand.state == Globals.handState.OPEN:
			if pourable && state == ActionType.FULL:
				state = ActionType.POURING
				$hePoured.play()
			dragging = false;

func _on_area_2d_area_entered(area):
	if area.name == "HandCollision" && !Globals.bookOpen:
		hand.pickedItem = self
		hand.setText("Ladle")

func _on_area_2d_area_exited(area):
	if area.name == "HandCollision":
		if hand.pickedItem == self: hand.pickedItem = null
		hand.clearText("Ladle")

func reset():
	pourable = false
	onBarrel = false
	state = ActionType.EMPTY
	sprite.texture = ladle_empty


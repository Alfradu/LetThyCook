extends Node

enum handState { OPEN, CLOSED }

@export var SOUPSTATS = {
	filling = 5,
	power = 5,
	taste = 5
}

@export var FoodItems = []

var soupLevel
var soupState
var test = 0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

var time = 0

func _process(delta):
	time += delta
	if (time > 1):
		time = 0
		degradeSoup()
		
func degradeSoup():
	for foodItem in FoodItems:
		if (foodItem.inSoup):
			foodItem.ttl -= 1

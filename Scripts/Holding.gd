extends Sprite2D

var onTable = false
var items = []

@onready var foodItem = load("res://Scenes/item.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
		
func _input(event):
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && onTable:
		for item in items:
			Globals.FoodItems.append(item)				
			var instantiateditem = foodItem.instantiate()
			$/root/Main/ItemContainer.add_child(instantiateditem)
			instantiateditem.init(item)
		onTable = false
		queue_free()

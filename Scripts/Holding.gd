extends Sprite2D

var onTable = false
var items = []
var hovering = false

@onready var foodItem = load("res://Scenes/item.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
		
func _input(event):
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && onTable && hovering:
		for item in items:
			Globals.FoodItems.append(item)
			var instantiateditem = foodItem.instantiate()
			$/root/Main/ItemContainer.add_child(instantiateditem)
			instantiateditem.init(item)
		onTable = false
		queue_free()

func _on_bowl_hit_box_area_entered(area):
	if area.name == "HandCollision":
		hovering = true
		if onTable: area.get_parent().setText("Unpack")

func _on_bowl_hit_box_area_exited(area):
	if area.name == "HandCollision":
		hovering = false
		if onTable: area.get_parent().clearText("Unpack")

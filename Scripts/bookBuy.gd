extends Node2D

var hovering = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _input(event):
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && hovering:
		if event.is_pressed(): 
			$/root/Main.showGreenBook()
			#open shop greenbook

func _on_area_2d_area_entered(area):
	if area.name == "HandCollision" && !Globals.bookOpen:
		area.get_parent().setText("Shop")
		hovering = true


func _on_area_2d_area_exited(area):
	if area.name == "HandCollision":
		area.get_parent().clearText("Shop")
		hovering = false

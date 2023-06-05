extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_area_2d_area_entered(area):
	if area.name == "HandCollision":
		area.get_parent().setText("Shop")


func _on_area_2d_area_exited(area):
	if area.name == "HandCollision":
		area.get_parent().clearText("Shop")

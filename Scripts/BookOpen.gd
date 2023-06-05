extends Node2D

enum bookCover { Red, Green}
@export var cover = bookCover.Red

@onready var red = load("res://Assets/books/bookred.png")
@onready var green = load("res://Assets/books/bookgreen.png")
# Called when the node enters the scene tree for the first time.
func _ready():
	match cover:
		bookCover.Red:
			$bookl.texture = red
			$bookr.texture = red
		bookCover.Green:
			$bookl.texture = green
			$bookr.texture = green

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

extends Node2D

@onready var sprite = $item
@onready var anchor = $/root/Main/cauldron/toolTipAnchor

var foodItem
var scaleSmall = Vector2(1, 1)
var scaleBig = Vector2(1.1, 1.1)
var targetScale = Vector2(1.1, 1.1)
var goingBig = true

# Called when the node enters the scene tree for the first time.
func _ready():
	self.position.x = 10000
	self.position.y = 10000

func init(item, texture):
	sprite.texture = texture
	foodItem = item

var time = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	if time > 1:
		$Label.text = str(foodItem.ttl)
		time = 0
	if foodItem.ttl <= 0:
		queue_free()

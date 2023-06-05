extends Control

var tooltips = []
@onready var anchor = $/root/Main/cauldron/toolTipAnchor

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var time = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	if time > 1:
		time = 0
		var tooltips = $/root/Main/cauldron/ItemToolTips.get_children()
		var xPosOffset = 0
		for toolTip in tooltips:
			toolTip.position = anchor.position
			toolTip.position.x -= xPosOffset
			xPosOffset += 61
		

extends Control

@onready var alert = load("res://Scenes/Alert.tscn")
@onready var anchor = $/root/Main/RefPoints/StatusMessageAnchor

var toBeAliveAlerts = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

var time = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	if time > 1:
		var text = toBeAliveAlerts.pop_front()
		if text != null:
			spawnAlert(text)
		time = 0
		var tooltips = $AlertContainer.get_children()
		tooltips.reverse()
		var yPosOffset = 0
		for toolTip in tooltips:
			if toolTip.ttl > 0:
				toolTip.position = anchor.position
				toolTip.position.y += yPosOffset
				yPosOffset += 80
			
func spawnAlert(text):
	var instantiateditem = alert.instantiate()
	instantiateditem.position = anchor.position
	$AlertContainer.add_child(instantiateditem)
	instantiateditem.get_node("Sprite2D/Message/Text").text = text


func setupMessage(text):
	toBeAliveAlerts.append(text)
	

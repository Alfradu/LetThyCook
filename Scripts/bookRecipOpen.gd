extends Node2D

var hoveringBackBtn = false
var hoveringNextBtn = false
var hoveringPrevBtn = false

var page = 3
var maxPage = 3
var minPage = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	endGame()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func _input(event):
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && Globals.bookOpen && Globals.book == self:
		if event.is_pressed() && hoveringBackBtn: 
			closeBook()
		elif event.is_pressed() && hoveringNextBtn: 
			nextPage()
		elif event.is_pressed() && hoveringPrevBtn: 
			prevPage()

func startGame():
	enableButton($backbtn/Sprite2D, $backbtn/backArea)
	closeBook()

func endGame():
	disableButton($backbtn/Sprite2D, $backbtn/backArea)
	openBook()

func openBook():
	$/root/Main/hand.point()
	$/root/Main/bookRecip/Sprite2Dshader.visible = false
	visible = true
	Globals.bookOpen = true
	Globals.book = self
	hoveringBackBtn = false
	hoveringNextBtn = false
	hoveringPrevBtn = false
	
func closeBook():
	$/root/Main/hand.grab()
	self.visible = false
	Globals.bookOpen = false

func nextPage():
	var prevNode = get_node("page"+str(page))
	page = minPage if page == maxPage else page + 1
	var nextNode = get_node("page"+str(page))
	prevNode.visible = false
	nextNode.visible = true
#	if (page == maxPage): 
#		disableButton($nextbtn/Sprite2D, $nextbtn/nextArea)
#	else:
#		enableButton($nextbtn/Sprite2D, $nextbtn/nextArea)
#	if (page == minPage): 
#		disableButton($prevbtn/Sprite2D, $prevbtn/prevArea)
#	else:
#		enableButton($prevbtn/Sprite2D, $prevbtn/prevArea)
	
func prevPage():
	var prevNode = get_node("page"+str(page))
	page = maxPage if page == minPage else page - 1
	var nextNode = get_node("page"+str(page))
	prevNode.visible = false
	nextNode.visible = true
#	if (page == maxPage): 
#		disableButton($nextbtn/Sprite2D, $nextbtn/nextArea)
#	else:
#		enableButton($nextbtn/Sprite2D, $nextbtn/nextArea)
#	if (page == minPage):
#		disableButton($prevbtn/Sprite2D, $prevbtn/prevArea)
#	else:
#		enableButton($prevbtn/Sprite2D, $prevbtn/prevArea)

func revealCombo(itemName):
	var nodes = get_tree().get_nodes_in_group("comboNodes")
	for node in nodes:
		if node.name == itemName && node.get_node("hidden").visible:
			node.get_node("hidden").visible = false
			$/root/Main/bookRecip/Sprite2Dshader.visible = true

func enableButton(sprite, area):
	sprite.self_modulate = Color(1, 1, 1, 1)
	area.monitoring = true

func disableButton(sprite, area):
	sprite.self_modulate = Color(0.5, 0.5, 0.5, 0.5)
	area.monitoring = false

func _on_back_area_area_entered(area):
	if area.name == "HandCollision" && visible:
		hoveringBackBtn = true
		hoveringNextBtn = false
		hoveringPrevBtn = false

func _on_back_area_area_exited(area):
	if area.name == "HandCollision" && visible:
		hoveringBackBtn = false

func _on_next_area_area_entered(area):
	if area.name == "HandCollision" && visible:
		hoveringNextBtn = true
		hoveringBackBtn = false
		hoveringPrevBtn = false

func _on_next_area_area_exited(area):
	if area.name == "HandCollision" && visible:
		hoveringNextBtn = false

func _on_prev_area_area_entered(area):
	if area.name == "HandCollision" && visible:
		hoveringPrevBtn = true
		hoveringBackBtn = false
		hoveringNextBtn = false

func _on_prev_area_area_exited(area):
	if area.name == "HandCollision" && visible:
		hoveringPrevBtn = false

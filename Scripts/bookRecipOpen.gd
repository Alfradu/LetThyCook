extends Node2D

var hoveringBackBtn = false
var hoveringNextBtn = false
var hoveringPrevBtn = false

var page = 1
var maxPage = 2
var minPage = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

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

func openBook():
		visible = true
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
	page += 1
	var nextNode = get_node("page"+str(page))
	prevNode.visible = false
	nextNode.visible = true
	if (page == maxPage): 
		disableButton($nextbtn/Sprite2D, $nextbtn/nextArea)
	else:
		enableButton($nextbtn/Sprite2D, $nextbtn/nextArea)
	if (page == minPage): 
		disableButton($prevbtn/Sprite2D, $prevbtn/prevArea)
	else:
		enableButton($prevbtn/Sprite2D, $prevbtn/prevArea)
	
func prevPage():
	var prevNode = get_node("page"+str(page))
	page -= 1
	var nextNode = get_node("page"+str(page))
	prevNode.visible = false
	nextNode.visible = true
	if (page == maxPage): 
		disableButton($nextbtn/Sprite2D, $nextbtn/nextArea)
	else:
		enableButton($nextbtn/Sprite2D, $nextbtn/nextArea)
	if (page == minPage):
		disableButton($prevbtn/Sprite2D, $prevbtn/prevArea)
	else:
		enableButton($prevbtn/Sprite2D, $prevbtn/prevArea)

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

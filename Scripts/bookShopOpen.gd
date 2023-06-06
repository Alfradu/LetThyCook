extends Node2D

var hoveringBackBtn = false
var hoveringNextBtn = false
var hoveringPrevBtn = false
var buyBtn
var buttonNodes
var ordered = false

var page = 1
var maxPage = 2
var minPage = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	buttonNodes = get_tree().get_nodes_in_group("shopBtns")
	for buttonNode in buttonNodes:
		disableButton(buttonNode.get_node("Sprite2D"), buttonNode.get_node("buyArea"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func _input(event):
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed() && hoveringBackBtn: 
			closeBook()
		elif event.is_pressed() && hoveringNextBtn: 
			nextPage()
		elif event.is_pressed() && hoveringPrevBtn: 
			prevPage()
		elif event.is_pressed() && buyBtn != null:
			orderItem()

func openBook():
		Globals.checkMoneyShop()
		visible = true
		hoveringBackBtn = false
		hoveringNextBtn = false
		hoveringPrevBtn = false
		
func closeBook():
	$/root/Main/hand.grab()
	self.visible = false
	Globals.bookOpen = false

func orderItem():
	Globals.orderItem(buyBtn[0], buyBtn[1])
	ordered = true

func checkMoney():
	for buttonNode in buttonNodes:
		var btnCost = buttonNode.get_parent().get_node("label2").text
		if costToInt(btnCost) > Globals.Money:
			disableButton(buttonNode.get_node("Sprite2D"), buttonNode.get_node("buyArea"))
		else:
			enableButton(buttonNode.get_node("Sprite2D"), buttonNode.get_node("buyArea"))
	ordered = false

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
	
func costToInt(costString):
	return int(costString.split(" ", true)[1])

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
	if (sprite.self_modulate == Color(1, 1, 1, 1)): return
	sprite.self_modulate = Color(1, 1, 1, 1)
	area.monitoring = true

func disableButton(sprite, area):
	if (sprite.self_modulate == Color(0.5, 0.5, 0.5, 0.5)): return
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

func _on_buy_area1_area_entered(_area):
	buyBtn = ["Potato", costToInt($page1/Sprite2D/label2.text)]
func _on_buy_area2_area_entered(_area):
	buyBtn = ["Carrot", costToInt($page1/Sprite2D2/label2.text)]
func _on_buy_area3_area_entered(_area):
	buyBtn = ["Cabbage", costToInt($page1/Sprite2D3/label2.text)]
func _on_buy_area4_area_entered(_area):
	buyBtn = ["Beef", costToInt($page1/Sprite2D4/label2.text)]
func _on_buy_area5_area_entered(_area):
	buyBtn = ["Pork", costToInt($page1/Sprite2D5/label2.text)]
func _on_buy_area6_area_entered(_area):
	buyBtn = ["Chicken", costToInt($page1/Sprite2D6/label2.text)]
func _on_buy_area7_area_entered(_area):
	buyBtn = ["Thyme", costToInt($page1/Sprite2D7/label2.text)]
func _on_buy_area8_area_entered(_area):
	buyBtn = ["Parsley", costToInt($page1/Sprite2D8/label2.text)]
func _on_buy_area9_area_entered(_area):
	buyBtn = ["Dill", costToInt($page1/Sprite2D9/label2.text)]

func _on_buy_area_area_exited(area):
	if !ordered: buyBtn = null

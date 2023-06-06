extends Node2D

var rng = RandomNumberGenerator.new()
@onready var spawnPoint = $RefPoints/spawnPoint
@onready var foodItem = load("res://Scenes/item.tscn")
@onready var humanItem = load("res://Scenes/human.tscn")

var time = 0
var state = Globals.TimeOfDay.MORNING
var untilDay = 5
var untilMorning = 10
var diffuculty = 1
var chillWithHumans = 0
var scoreAtStart = 0

func _ready():
	for item in Globals.FoodItems:
		var instantiateditem = foodItem.instantiate()
		$ItemContainer.add_child(instantiateditem)
		instantiateditem.init(item)

func _process(delta):
	if Globals.gameState == Globals.gameStateType.MENU: return 
	if Globals.gameState == Globals.gameStateType.END: return 
	time += delta * diffuculty
	if (time > 1):
		time = 0
		chillWithHumans -= 1
		Globals.degradeSoupItems(1)
		Globals.calculateSoup()
		maybeSendInHuman(Globals.Orders)
		if (state == Globals.TimeOfDay.MORNING):
			untilDay -= 1
		if (state == Globals.TimeOfDay.DAY):
			maybeSendInHuman(Globals.Population)
			checkRoundOver()
		if (state == Globals.TimeOfDay.NIGHT):
			untilMorning -= 1
		maybeChangeState()
		Globals.Score += 1

func updateLabels():
	$HUD/Filling.value = Globals.SOUPSTATS.filling
	$HUD/Power.value = Globals.SOUPSTATS.power
	$HUD/Taste.value = Globals.SOUPSTATS.taste
	$HUD/PeopleLeft/Label2.text = str(toFeed())
	$HUD/Money/Label2.text = formatScore(Globals.Money)
	$HUD/Score.text = "Score: " + formatScore(Globals.Score)
	if Globals.combo > 1: 
		$HUD/container/AnimationPlayer.play("pulse")
		$HUD/container.visible = true
		$HUD/container/combo.text = "Combo! x" + str(Globals.combo)
	else:
		$HUD/container/AnimationPlayer.pause()
		$HUD/container.visible = false

func formatScore(num):
	return "%06d" % num

func toFeed():
	var count = 0
	for item in Globals.Population:
		if item.holdingBowl:
			count += 1
	return count

func maybeSendInHuman(list):
	if chillWithHumans > 0:
		return
	if (!spawnPoint.isOccupied):
		var human = list.pop_front()
		if (human != null):
			var instantiateditem = humanItem.instantiate()
			$HumanContainer.add_child(instantiateditem)
			instantiateditem.init(human)
			if human.holdingBox: Globals.deliveryBoys += 1
			chillWithHumans = 2

func checkRoundOver():
	if ($HumanContainer.get_child_count()-Globals.deliveryBoys == 0 && Globals.Population.is_empty()):
		state = Globals.TimeOfDay.NIGHT
		$AnimationPlayer.play("set")
		$HUD.setupMessage("Good job!")
		$HUD.setupMessage("Money Earned Today: " + str(Globals.MoneyToday))
		$HUD.setupMessage("Score Earned Today: " + str(Globals.Score - scoreAtStart))

func maybeChangeState():
	if (state == Globals.TimeOfDay.MORNING && untilDay <= 0):
		state = Globals.TimeOfDay.DAY
		untilDay = 5
		scoreAtStart = Globals.Score
		$HUD.setupMessage("Lets go!")
		$AnimationPlayer.play("rise")
	if (state == Globals.TimeOfDay.NIGHT && untilMorning <= 0):
		Globals.ToBePopulated.shuffle()
		for human in Globals.ToBePopulated:
			Globals.Population.append(human)
			human.satisfaction = 0
		Globals.MoneyToday = 0
		state = Globals.TimeOfDay.MORNING
		Globals.ToBePopulated = []
		untilMorning = 10
		$HUD.setupMessage("Good Morning, Prepare yourself!")
		for human in Globals.Rip:
			var message = "Unfortunately, " + human.name + " died"
			$HUD.setupMessage(message)
		Globals.Rip.clear()
		diffuculty += 0.5

func showRedBook():
	$hand.point()
	Globals.bookOpen = true
	$bookRecipOpen.openBook()

func showGreenBook():
	$hand.point()
	Globals.bookOpen = true
	$bookBuyOpen.openBook()

func _on_audio_stream_player_2d_finished():
	$AudioStreamPlayer2D.play()


func _on_animation_player_animation_finished(anim_name):
	if (anim_name == "set"):
		$AnimationPlayer.play("night_passing")

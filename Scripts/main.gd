extends Node2D

var rng = RandomNumberGenerator.new()

@onready var spawnPoint = $RefPoints/spawnPoint

func setupPopulation(Population):
	for i in range(2):
		var human = Globals.Human.new()
		human.name = "Jörgen"
		human.status = Globals.Rank.PEASANT
		human.foodType = Globals.FoodType.VEGETABLE
		human.holdingBowl = true
		human.hunger = Globals.Hunger.HUNGRY
		human.fat = false
		Population.append(human)
	for i in range(2):
		var human = Globals.Human.new()
		human.name = "Jörgen"
		human.status = Globals.Rank.PEASANT
		human.foodType = Globals.FoodType.VEGETABLE
		human.holdingBowl = true
		human.hunger = Globals.Hunger.HUNGRY
		human.fat = true
		Population.append(human)
	for i in range(3):
		var human = Globals.Human.new()
		human.name = "Bengt"
		human.status = Globals.Rank.SOLDIER
		human.foodType = Globals.FoodType.PROTEIN
		human.holdingBowl = true
		human.fat = false
		human.hunger = Globals.Hunger.CONTEMPT
		Population.append(human)
	for i in range(1):
		var human = Globals.Human.new()
		human.name = "Gaylord"
		human.status = Globals.Rank.NOBLE
		human.foodType = Globals.FoodType.HERB
		human.holdingBowl = true
		human.fat = false
		human.hunger = Globals.Hunger.FULL
		Population.append(human)
	
@onready var foodItem = load("res://Scenes/item.tscn")
@onready var humanItem = load("res://Scenes/human.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	setupPopulation(Globals.Population)
	Globals.Population.shuffle()
#
	for item in Globals.FoodItems:
		var instantiateditem = foodItem.instantiate()
		$ItemContainer.add_child(instantiateditem)
		instantiateditem.init(item)

var time = 0
var state = Globals.TimeOfDay.MORNING
var untilDay = 5
var untilMorning = 10
var diffuculty = 1
var chillWithHumans = 0
var scoreAtStart = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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
	$/root/Main/HUD/Filling.value = Globals.SOUPSTATS.filling
	$/root/Main/HUD/Power.value = Globals.SOUPSTATS.power
	$/root/Main/HUD/Taste.value = Globals.SOUPSTATS.taste
	$/root/Main/HUD/PeopleLeft/Label2.text = str(toFeed())
	$/root/Main/HUD/Money/Label2.text = formatScore(Globals.Money)
	$/root/Main/HUD/Score.text = "Score: " + formatScore(Globals.Score)
	
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
		$HUD.setupMessage("Good job!")
		$HUD.setupMessage("Money Earned Today: " + str(Globals.MoneyToday))
		$HUD.setupMessage("Score Earned Today: " + str(Globals.Score - scoreAtStart))

func maybeChangeState():
	if (state == Globals.TimeOfDay.MORNING && untilDay <= 0):
		state = Globals.TimeOfDay.DAY
		untilDay = 5
		scoreAtStart = Globals.Score
		$HUD.setupMessage("Lets go!")
	if (state == Globals.TimeOfDay.NIGHT && untilMorning <= 0):
		Globals.ToBePopulated.shuffle()
		for human in Globals.ToBePopulated:
			Globals.Population.append(human)
			human.satisfaction = 0
		Globals.MoneyToday = 0
		state = Globals.TimeOfDay.MORNING
		Globals.ToBePopulated = []
		untilMorning = 15
		$HUD.setupMessage("Good Morning, Prepare yourself!")
		for human in Globals.Rip:
			var message = "Unfortunately, " + human.name + " died"
			$HUD.setupMessage(message)
		Globals.Rip.clear()

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

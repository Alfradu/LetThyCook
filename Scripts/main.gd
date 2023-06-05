extends Node2D

var rng = RandomNumberGenerator.new()

@onready var spawnPoint = $RefPoints/spawnPoint

func setupPopulation(Population):
	for i in range(11):
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
	
	for item in Globals.FoodItems:
		var instantiateditem = foodItem.instantiate()
		$ItemContainer.add_child(instantiateditem)
		instantiateditem.init(item)

var time = 0
var state = Globals.TimeOfDay.MORNING
var untilDay = 2
var untilMorning = 4
var delivery = 0
var diffuculty = 1
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta * diffuculty
	delivery += delta * diffuculty
	if (delivery > 5):
		delivery = 0
		maybeSendInHuman(Globals.Orders)
	elif (time > 1):
		time = 0
		Globals.degradeSoupItems(1)
		Globals.calculateSoup()
		if (state == Globals.TimeOfDay.MORNING):
			untilDay -= 1
		if (state == Globals.TimeOfDay.DAY):
			maybeSendInHuman(Globals.Population)
			checkRoundOver()
		if (state == Globals.TimeOfDay.NIGHT):
			untilMorning -= 1
		maybeChangeState()

func updateLabels():
	$/root/Main/Filling.value = Globals.SOUPSTATS.filling
	$/root/Main/Filling/Label.text = "Filling: %d%%" % Globals.SOUPSTATS.filling
	$/root/Main/Power.value = Globals.SOUPSTATS.power
	$/root/Main/Power/Label.text = "Power: %d%%" % Globals.SOUPSTATS.power
	$/root/Main/Taste.value = Globals.SOUPSTATS.taste
	$/root/Main/Taste/Label.text = "Taste: %d%%" % Globals.SOUPSTATS.taste
	$/root/Main/TimeNow.text = str(Globals.TimeOfDay.keys()[state]) + " " + str(untilDay if state == Globals.TimeOfDay.MORNING else untilMorning)
	$/root/Main/SoupLevel.text = "Soup level: " + str(Globals.cauldronLevels.keys()[Globals.soupLevel])

func maybeSendInHuman(list):
	if (!spawnPoint.isOccupied):
		var human = list.pop_front()
		if (human != null):
			var instantiateditem = humanItem.instantiate()
			$HumanContainer.add_child(instantiateditem)
			instantiateditem.init(human)
			
func checkRoundOver():
	if ($HumanContainer.get_child_count() == 0 && Globals.Population.is_empty()):
		state = Globals.TimeOfDay.NIGHT

func maybeChangeState():
	if (state == Globals.TimeOfDay.MORNING && untilDay <= 0):
		Globals.ToBePopulated.shuffle()
		for human in Globals.ToBePopulated:
			Globals.Population.append(human)
			human.satisfaction = 0
		state = Globals.TimeOfDay.DAY
		Globals.ToBePopulated = []
		untilDay = 5
	if (state == Globals.TimeOfDay.NIGHT && untilMorning <= 0):
		state = Globals.TimeOfDay.MORNING
		untilMorning = 10

func showRedBook():
	pass
	
func showGreenBook():
	pass

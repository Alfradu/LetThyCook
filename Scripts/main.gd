extends Node2D

var rng = RandomNumberGenerator.new()

@onready var spawnPoint = $RefPoints/spawnPoint

func setupFoodItems(FoodItems):
	FoodItems.append(getFoodItem("Carrot", Globals.FoodType.VEGETABLE))
	FoodItems.append(getFoodItem("Carrot", Globals.FoodType.VEGETABLE))
	FoodItems.append(getFoodItem("Carrot", Globals.FoodType.VEGETABLE))
	FoodItems.append(getFoodItem("Potato", Globals.FoodType.VEGETABLE))
	FoodItems.append(getFoodItem("Potato", Globals.FoodType.VEGETABLE))
	FoodItems.append(getFoodItem("Potato", Globals.FoodType.VEGETABLE))
	FoodItems.append(getFoodItem("Cabbage", Globals.FoodType.PROTEIN))
#	FoodItems.append(getFoodItem("Beef", FoodType.PROTEIN))
#	FoodItems.append(getFoodItem("Chicken", FoodType.PROTEIN))
#	FoodItems.append(getFoodItem("Thyme", FoodType.HERB))
#	FoodItems.append(getFoodItem("Parsley", FoodType.HERB))
	
func getFoodItem(itemName, type, stats: Globals.FoodStats = null):
	var item = Globals.FoodItem.new()
	item.name = itemName
	item.type = type
	item.ttl = rng.randf_range(60, 120)
	item.hiddenCombo = getHiddenCombo(itemName)
	
	var itemStats = Globals.FoodStats.new()
	itemStats.filling = stats.filling if stats != null else getFilling(type)
	itemStats.power = stats.power if stats != null else getPower(type)
	itemStats.taste = stats.taste if stats != null else getTaste(type)
	
	item.stats = itemStats
	
	return item
	
func getFilling(type):
	if (type == Globals.FoodType.VEGETABLE):
		return rng.randi_range(20, 40)
	if (type == Globals.FoodType.PROTEIN):
		return rng.randi_range(5, 30)
	if (type == Globals.FoodType.HERB):
		return rng.randi_range(0, 15)

func getPower(type):
	if (type == Globals.FoodType.VEGETABLE):
		return rng.randi_range(0, 25)
	if (type == Globals.FoodType.PROTEIN):
		return rng.randi_range(30, 50)
	if (type == Globals.FoodType.HERB):
		return rng.randi_range(0, 15)

func getTaste(type):
	if (type == Globals.FoodType.VEGETABLE):
		return rng.randi_range(10, 30)
	if (type == Globals.FoodType.PROTEIN):
		return rng.randi_range(40, 50)
	if (type == Globals.FoodType.HERB):
		return rng.randi_range(40, 60)
		
func getHiddenCombo(itemName):
	if (itemName == "Carrot"):
		return "Potato"
	return ""

func setupPopulation(Population):
	for i in range(14):
		var human = Globals.Human.new()
		human.name = "Jörgen"
		human.status = Globals.Rank.PEASANT
		human.foodType = Globals.FoodType.VEGETABLE
		human.holdingBowl = true
		human.hunger = Globals.Hunger.HUNGRY
		Population.append(human)
	for i in range(4):
		var human = Globals.Human.new()
		human.name = "Bengt"
		human.status = Globals.Rank.SOLDIER
		human.foodType = Globals.FoodType.PROTEIN
		human.holdingBowl = true
		human.hunger = Globals.Hunger.CONTEMPT
		Population.append(human)
	for i in range(2):
		var human = Globals.Human.new()
		human.name = "Gaylord"
		human.status = Globals.Rank.NOBLE
		human.foodType = Globals.FoodType.HERB
		human.holdingBowl = true
		human.hunger = Globals.Hunger.FULL
		Population.append(human)
	
@onready var foodItem = load("res://Scenes/item.tscn")
@onready var humanItem = load("res://Scenes/human.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	setupFoodItems(Globals.FoodItems)
	setupPopulation(Globals.Population)
	
	for item in Globals.FoodItems:
		var instantiateditem = foodItem.instantiate()
		$ItemContainer.add_child(instantiateditem)
		instantiateditem.init(item)

var time = 0
var state = Globals.TimeOfDay.MORNING
var untilDay = 2
var untilMorning = 30
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	if (time > 1):
		time = 0
		Globals.degradeSoupItems(1)
		Globals.calculateSoup()
		updateLabels()
		if (state == Globals.TimeOfDay.MORNING):
			untilDay -= 1
		if (state == Globals.TimeOfDay.DAY):
			maybeSendInHuman()
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
		
func maybeSendInHuman():
	if (!spawnPoint.isOccupied):
		var human = Globals.Population.pop_front()
		if (human != null):
			var instantiateditem = humanItem.instantiate()
			$HumanContainer.add_child(instantiateditem)
			instantiateditem.init(human)
			
func checkRoundOver():
	if ($HumanContainer.get_child_count() == 0 && Globals.Population.is_empty()):
		state = Globals.TimeOfDay.NIGHT

func maybeChangeState():
	if (state == Globals.TimeOfDay.MORNING && untilDay <= 0):
		state = Globals.TimeOfDay.DAY
		untilDay = 15
	if (state == Globals.TimeOfDay.NIGHT && untilMorning <= 0):
		state = Globals.TimeOfDay.MORNING
		untilMorning = 30

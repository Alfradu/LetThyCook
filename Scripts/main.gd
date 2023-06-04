extends Node2D

var rng = RandomNumberGenerator.new()

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
		return rng.randi_range(70, 100)
	if (type == Globals.FoodType.PROTEIN):
		return rng.randi_range(30, 80)
	if (type == Globals.FoodType.HERB):
		return rng.randi_range(0, 20)

func getPower(type):
	if (type == Globals.FoodType.VEGETABLE):
		return rng.randi_range(30, 50)
	if (type == Globals.FoodType.PROTEIN):
		return rng.randi_range(60, 100)
	if (type == Globals.FoodType.HERB):
		return rng.randi_range(20, 30)

func getTaste(type):
	if (type == Globals.FoodType.VEGETABLE):
		return rng.randi_range(10, 80)
	if (type == Globals.FoodType.PROTEIN):
		return rng.randi_range(40, 100)
	if (type == Globals.FoodType.HERB):
		return rng.randi_range(70, 100)
		
func getHiddenCombo(itemName):
	if (itemName == "Carrot"):
		return "Potato"
	return ""

func setupPopulation():
	return

@onready var foodItem = load("res://Scenes/item.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	setupFoodItems(Globals.FoodItems)
	setupPopulation()
	
	print(foodItem)

	for item in Globals.FoodItems:
		var instantiateditem = foodItem.instantiate()
		$ItemContainer.add_child(instantiateditem)
		instantiateditem.init(item)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

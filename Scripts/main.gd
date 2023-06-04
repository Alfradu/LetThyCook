extends Node2D

enum FoodType { VEGETABLE, PROTEIN, HERB }

class FoodStats:
	var filling: int
	var power: int
	var taste: int

class FoodItem:
	var name: String
	var type: FoodType
	var stats: FoodStats
	var ttl: int
	var inSoup: bool
	var hiddenCombo: String
	
var rng = RandomNumberGenerator.new()

func setupFoodItems(FoodItems):
	FoodItems.append(getFoodItem("Carrot", FoodType.VEGETABLE))
	FoodItems.append(getFoodItem("Carrot", FoodType.VEGETABLE))
	FoodItems.append(getFoodItem("Carrot", FoodType.VEGETABLE))
	FoodItems.append(getFoodItem("Potato", FoodType.VEGETABLE))
	FoodItems.append(getFoodItem("Potato", FoodType.VEGETABLE))
	FoodItems.append(getFoodItem("Potato", FoodType.VEGETABLE))
	FoodItems.append(getFoodItem("Cabbage", FoodType.VEGETABLE))
#	FoodItems.append(getFoodItem("Beef", FoodType.PROTEIN))
#	FoodItems.append(getFoodItem("Chicken", FoodType.PROTEIN))
#	FoodItems.append(getFoodItem("Thyme", FoodType.HERB))
#	FoodItems.append(getFoodItem("Parsley", FoodType.HERB))
	
func getFoodItem(name, type, stats: FoodStats = null):
	var item = FoodItem.new()
	item.name = name
	item.type = type
	item.ttl = rng.randf_range(60, 120)
	item.hiddenCombo = getHiddenCombo(name)
	
	var itemStats = FoodStats.new()
	itemStats.filling = stats.filling if stats != null else getFilling(type)
	itemStats.power = stats.power if stats != null else getPower(type)
	itemStats.taste = stats.taste if stats != null else getTaste(type)
	
	item.stats = itemStats
	
	return item
	
func getFilling(type):
	if (type == FoodType.VEGETABLE):
		return rng.randi_range(7, 10)
	if (type == FoodType.PROTEIN):
		return rng.randi_range(3, 8)
	if (type == FoodType.HERB):
		return rng.randi_range(0, 2)

func getPower(type):
	if (type == FoodType.VEGETABLE):
		return rng.randi_range(3, 5)
	if (type == FoodType.PROTEIN):
		return rng.randi_range(6, 10)
	if (type == FoodType.HERB):
		return rng.randi_range(2, 3)

func getTaste(type):
	if (type == FoodType.VEGETABLE):
		return rng.randi_range(1, 8)
	if (type == FoodType.PROTEIN):
		return rng.randi_range(4, 10)
	if (type == FoodType.HERB):
		return rng.randi_range(7, 10)
		
func getHiddenCombo(name):
	if (name == "Carrot"):
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
func _process(delta):
	pass
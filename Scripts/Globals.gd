extends Node

var rng = RandomNumberGenerator.new()
	
enum handState { OPEN, CLOSED }
enum FoodType { VEGETABLE = 0, PROTEIN = 1, HERB = 2 }
enum Rank { PEASANT = 0, SOLDIER = 1, NOBLE = 2 }
enum Hunger { ALMOSTDEAD = 0, HUNGRY = 1, CONTEMPT = 2, FULL = 3}
enum HumanState { IDLE, WALKING_TO_CAULDRON, TAKING, WALKING_TO_END, DONE }
enum TimeOfDay { MORNING, DAY, NIGHT }
enum cauldronState { UNEATABLE = 0, BAD = 1, PRETTYGOOD = 2, AMAZING = 3}
enum cauldronLevels { EMPTY = 0, ALMOSTEMPTY = 1, PRETTYFULL = 2, FULL = 3} 

@export var SOUPSTATS = {
	filling = 0,
	power = 0,
	taste = 0,
	umami = 0
}

@export var FoodItems = []
@export var Population = []
@export var Orders = []
var ToBePopulated = []

var soupLevel
var soupedPeople = 0

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
	var hiddenCombo: String #TODO: remove?

class Human:
	var name: String
	var status: Rank
	var foodType: FoodType
	var holdingBowl: bool
	var holdingBox: bool
	var boxContent: Array
	var isDead: bool
	var hunger: Hunger
	var satisfaction: int
	var ateSoupLevel: int
	var fat: bool
	
	var rng = RandomNumberGenerator.new()
	
	func humandideat():
		if Globals.soupLevel == cauldronLevels.EMPTY: return
		var partOfSoupWithpreference = 0.0
		var itemsInSoup = 0
		for item in Globals.FoodItems:
			if item.inSoup:
				itemsInSoup += 1
				if item.type == foodType:
					partOfSoupWithpreference += 1
		partOfSoupWithpreference = partOfSoupWithpreference / itemsInSoup if itemsInSoup > 0 else 1.0
		
		self.ateSoupLevel = Globals.SOUPSTATS.umami
		self.satisfaction = (Globals.SOUPSTATS.filling + Globals.SOUPSTATS.power + Globals.SOUPSTATS.taste) / 3 + (40 * partOfSoupWithpreference)
		var willBeFat = self.hunger == Globals.Hunger.FULL
		self.hunger = self.hunger + 2 as Globals.Hunger if self.hunger+2 < Globals.Hunger.FULL else Globals.Hunger.FULL
		Globals.soupedPeople +=1
		if self.fat:
			Globals.soupedPeople = 0
			Globals.updateCauldronLevel(-2)
		elif Globals.soupedPeople % 3 == 0:
			Globals.soupedPeople = 0
			Globals.updateCauldronLevel(-1)
			
		if self.satisfaction > 80 && rng.randf_range(0, 10) > 5:
			self.holdingBowl = false
			self.holdingBox = true
			for i in range(rng.randi_range(1,3)):
				self.boxContent.append(Globals.getFoodItem())
			Globals.Orders.append(self)
			
		self.fat = willBeFat
	
	func degradehuman():
		self.hunger = self.hunger - 1 as Globals.Hunger if self.hunger-1 > Globals.Hunger.ALMOSTDEAD else Globals.Hunger.ALMOSTDEAD
		if hunger <= 0:
			isDead = true

var time = 0
var foodLibrary = [
	{ name = "Potato",  type = FoodType.VEGETABLE, combo = "Pork",   discovered = false, cost = 5,  modifier = 0},
	{ name = "Carrot",  type = FoodType.VEGETABLE, combo = "potato", discovered = false, cost = 5,  modifier = 0},
	{ name = "Cabbage", type = FoodType.VEGETABLE, combo = "Beef",   discovered = false, cost = 5,  modifier = 0},
#	{ name = "Onion",   type = FoodType.VEGETABLE, combo = "Fish",   discovered = false, cost = 15, modifier = 10},
#	{ name = "Garlic",  type = FoodType.VEGETABLE, combo = "Chicken",discovered = false, cost = 15, modifier = 10},
#	{ name = "Turnip",  type = FoodType.VEGETABLE, combo = "Thyme",  discovered = false, cost = 10, modifier = 5},
#	{ name = "Beans",   type = FoodType.VEGETABLE, combo = "Onion",  discovered = false, cost = 20, modifier = 15},
	{ name = "Beef",    type = FoodType.PROTEIN,   combo = "Thyme",  discovered = false, cost = 25, modifier = 20},
	{ name = "Pork",    type = FoodType.PROTEIN,   combo = "Parsley",discovered = false, cost = 30, modifier = 20},
	{ name = "Chicken", type = FoodType.PROTEIN,   combo = "Carrot", discovered = false, cost = 35, modifier = 20},
#	{ name = "Fish",    type = FoodType.PROTEIN,   combo = "Dill",   discovered = false, cost = 55, modifier = 20},
	{ name = "Thyme",   type = FoodType.HERB,      combo = "Parsley",discovered = false, cost = 50, modifier = 20},
	{ name = "Parsley", type = FoodType.HERB,      combo = "Potato", discovered = false, cost = 60, modifier = 40},
	{ name = "Dill",    type = FoodType.HERB,      combo = "Fish",   discovered = false, cost = 55, modifier = 30},
#	{ name = "Salt",    type = FoodType.HERB,      combo = "",       discovered = false, cost = 50, modifier = 50},
#	{ name = "Pepper",  type = FoodType.HERB,      combo = "",       discovered = false, cost = 50, modifier = 50}
] 

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	setupFoodItems()

func _process(_delta):
	pass

func degradeSoupItems(damage):
	for foodItem in FoodItems:
		if (foodItem.inSoup):
			foodItem.ttl -= damage
		if (foodItem.ttl <= 0):
			foodItem.inSoup = false

func calculateSoup():
	var cur_filling = 0
	var cur_power = 0
	var cur_taste = 0

	for foodItem in FoodItems:
		if (foodItem.inSoup):
			var potency = foodItem.ttl / 60.0
			cur_filling += foodItem.stats.filling * potency
			cur_power += foodItem.stats.power * potency
			cur_taste += foodItem.stats.taste * potency
		
	SOUPSTATS.filling = cur_filling if cur_filling < 100 else 100 
	SOUPSTATS.power = cur_power if cur_power < 100 else 100
	SOUPSTATS.taste = cur_taste if cur_taste < 100 else 100
	
	var quality = ((SOUPSTATS.filling + SOUPSTATS.power + SOUPSTATS.taste) / 3) - 1
	
	var oldSoupState = SOUPSTATS.umami
	SOUPSTATS.umami = int(quality / 25)
	
	if oldSoupState != SOUPSTATS.umami:
		$/root/Main/cauldron.stateupdate = true

func updateCauldronLevel(nr):
	$/root/Main/cauldron.updateLevel(nr)
	

func setupFoodItems():
	FoodItems.append(getFoodItem("Carrot"))
	FoodItems.append(getFoodItem("Carrot"))
	FoodItems.append(getFoodItem("Carrot"))
	FoodItems.append(getFoodItem("Potato"))
	FoodItems.append(getFoodItem("Potato"))
	FoodItems.append(getFoodItem("Potato"))
	FoodItems.append(getFoodItem("Cabbage"))
	FoodItems.append(getFoodItem("Beef"))
	FoodItems.append(getFoodItem("Pork"))
	FoodItems.append(getFoodItem("Chicken"))
	FoodItems.append(getFoodItem("Thyme"))
	FoodItems.append(getFoodItem("Parsley"))
	FoodItems.append(getFoodItem("Dill"))
	
func getFoodItem(itemName = "", stats: FoodStats = null):
	var item = getRandomItem() if itemName == "" else getFoodFromLibrary(itemName) #TODO: can crash here if we dont find name in lib
	var i = FoodItem.new()
	i.name = item.name
	i.type = item.type
	i.ttl = rng.randf_range(60, 120)
	i.hiddenCombo = item.combo
	
	var itemStats = FoodStats.new()
	itemStats.filling = stats.filling if stats != null else getFilling(item)
	itemStats.power = stats.power if stats != null else getPower(item)
	itemStats.taste = stats.taste if stats != null else getTaste(item)
	
	i.stats = itemStats
	return i
	
func getRandomItem():
	return foodLibrary[rng.randi_range(0, foodLibrary.size()-1)];
	
func getFoodFromLibrary(foodName):
	for item in foodLibrary:
		if foodName == item.name: return item
	return null

func getFilling(item):
	if (item.type == FoodType.VEGETABLE):
		return rng.randi_range(20, 40)+item.modifier
	if (item.type == FoodType.PROTEIN):
		return rng.randi_range(5, 30)+item.modifier
	if (item.type == FoodType.HERB):
		return rng.randi_range(0, 15)+item.modifier

func getPower(item):
	if (item.type == FoodType.VEGETABLE):
		return rng.randi_range(0, 25)+item.modifier
	if (item.type == FoodType.PROTEIN):
		return rng.randi_range(30, 50)+item.modifier
	if (item.type == FoodType.HERB):
		return rng.randi_range(0, 15)+item.modifier

func getTaste(item):
	if (item.type == FoodType.VEGETABLE):
		return rng.randi_range(10, 30)+item.modifier
	if (item.type == FoodType.PROTEIN):
		return rng.randi_range(40, 50)+item.modifier
	if (item.type == FoodType.HERB):
		return rng.randi_range(40, 60)+item.modifier

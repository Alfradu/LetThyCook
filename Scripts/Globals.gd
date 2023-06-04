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
	var hiddenCombo: String

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
		partOfSoupWithpreference = partOfSoupWithpreference / itemsInSoup if itemsInSoup > 0 else 1
		
		self.ateSoupLevel = Globals.SOUPSTATS.umami
		self.satisfaction = (Globals.SOUPSTATS.filling + Globals.SOUPSTATS.power + Globals.SOUPSTATS.taste) / 3 + (40 * partOfSoupWithpreference)
		self.hunger = self.hunger + 2 as Globals.Hunger if self.hunger+2 < Globals.Hunger.FULL else Globals.Hunger.FULL
		Globals.soupedPeople +=1
		if self.fat:
			Globals.soupedPeople = 0
			Globals.updateCauldronLevel(-2)
		elif Globals.soupedPeople % 3 == 0:
			Globals.soupedPeople = 0
			Globals.updateCauldronLevel(-1)
			
		if self.satisfaction > 100 && rng.randf_range(0, 10) > 7:
			self.holdingBowl = false
			self.holdingBox = true
			for i in range(rng.randi_range(1,3)):
				self.boxContent.append(Globals.getFoodItem())
			Globals.Orders.append(self)
	
	func degradehuman():
		self.hunger = self.hunger - 1 as Globals.Hunger if self.hunger-1 > Globals.Hunger.ALMOSTDEAD else Globals.Hunger.ALMOSTDEAD
		if hunger <= 0:
			isDead = true
	
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	setupFoodItems()

var time = 0

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
	FoodItems.append(getFoodItem("Carrot", Globals.FoodType.VEGETABLE))
	FoodItems.append(getFoodItem("Carrot", Globals.FoodType.VEGETABLE))
	FoodItems.append(getFoodItem("Carrot", Globals.FoodType.VEGETABLE))
	FoodItems.append(getFoodItem("Potato", Globals.FoodType.VEGETABLE))
	FoodItems.append(getFoodItem("Potato", Globals.FoodType.VEGETABLE))
	FoodItems.append(getFoodItem("Potato", Globals.FoodType.VEGETABLE))
	FoodItems.append(getFoodItem("Cabbage", Globals.FoodType.VEGETABLE))
	FoodItems.append(getFoodItem("Beef", Globals.FoodType.PROTEIN))
	FoodItems.append(getFoodItem("Pork", Globals.FoodType.PROTEIN))
	FoodItems.append(getFoodItem("Chicken", Globals.FoodType.PROTEIN))
	FoodItems.append(getFoodItem("Thyme", Globals.FoodType.HERB))
	FoodItems.append(getFoodItem("Parsley", Globals.FoodType.HERB))
	FoodItems.append(getFoodItem("Dill", Globals.FoodType.HERB))
	
func getFoodItem(itemName = "", type = null, stats: Globals.FoodStats = null):
	if (itemName == "" && type == null):
		type = getRandomType()
		itemName = getName(type) 
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
	
func getRandomType():
	return Globals.FoodType.VEGETABLE
	
func getName(type):
	if (type == Globals.FoodType.VEGETABLE):
		return "carrot"

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

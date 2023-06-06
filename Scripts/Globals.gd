extends Node

var rng = RandomNumberGenerator.new()

enum gameStateType { MENU, START, END}
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

var FoodItems = []
var Population = []
var Orders = []
var ToBePopulated = []
var Rip = []

var Score = 0
var Money = 0
var MoneyToday = 0

var soupLevel
var soupedPeople = 0
var bookOpen = false
var book = null
var deliveryBoys = 0

var gameState = gameStateType.MENU

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
		self.fat = self.hunger == Globals.Hunger.FULL && Globals.soupLevel != cauldronLevels.EMPTY
		if Globals.soupLevel != cauldronLevels.EMPTY: 
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
			self.hunger = self.hunger + 2 as Globals.Hunger if self.hunger+2 < Globals.Hunger.FULL else Globals.Hunger.FULL
			Globals.soupedPeople +=1
			if self.fat:
				Globals.soupedPeople = 0
				Globals.updateCauldronLevel(-2)
			elif Globals.soupedPeople % 3 == 0:
				Globals.soupedPeople = 0
				Globals.updateCauldronLevel(-1)
				
			if self.satisfaction > 80 && rng.randf_range(0, 10) > 7:
				var deliveryGuy = Human.new()
				deliveryGuy.name = "Karl-Bertil"
				deliveryGuy.status = Rank.PEASANT
				deliveryGuy.foodType = FoodType.VEGETABLE
				deliveryGuy.holdingBowl = false
				deliveryGuy.holdingBox = true
				deliveryGuy.hunger = Hunger.CONTEMPT
				deliveryGuy.fat = false
				for i in range(rng.randi_range(1,3)):
					var item = Globals.getFoodItem()
					deliveryGuy.boxContent.append(item)
					Globals.FoodItems.append(item)
					self.boxContent.append(item)
				
				Globals.Orders.append(deliveryGuy)
	
	func degradehuman():
		self.hunger = self.hunger - 1 as Globals.Hunger if self.hunger-1 > Globals.Hunger.ALMOSTDEAD else Globals.Hunger.ALMOSTDEAD
		if hunger <= 0:
			isDead = true

func setupPopulation(pop):
	for i in range(2):
		var human = Human.new()
		human.name = "Jörgen"
		human.status = Rank.PEASANT
		human.foodType = FoodType.VEGETABLE
		human.holdingBowl = true
		human.hunger = Globals.Hunger.HUNGRY
		human.fat = false
		pop.append(human)
	for i in range(2):
		var human = Human.new()
		human.name = "Jörgen"
		human.status = Rank.PEASANT
		human.foodType = FoodType.VEGETABLE
		human.holdingBowl = true
		human.hunger = Hunger.HUNGRY
		human.fat = true
		pop.append(human)
	for i in range(3):
		var human = Human.new()
		human.name = "Bengt"
		human.status = Rank.SOLDIER
		human.foodType = FoodType.PROTEIN
		human.holdingBowl = true
		human.fat = false
		human.hunger = Globals.Hunger.CONTEMPT
		pop.append(human)
	for i in range(1):
		var human = Human.new()
		human.name = "Gaylord"
		human.status = Rank.PEASANT
		human.foodType = FoodType.HERB
		human.holdingBowl = true
		human.fat = false
		human.hunger = Globals.Hunger.FULL
		pop.append(human)

var foodLibrary = [
	{ name = "Potato",  type = FoodType.VEGETABLE, combo = "Pork",   discovered = false, cost = 5,  modifier = 0},
	{ name = "Carrot",  type = FoodType.VEGETABLE, combo = "Cabbage", discovered = false, cost = 5,  modifier = 0},
	{ name = "Cabbage", type = FoodType.VEGETABLE, combo = "Beef",   discovered = false, cost = 5,  modifier = 0},
#	{ name = "Onion",   type = FoodType.VEGETABLE, combo = "Fish",   discovered = false, cost = 15, modifier = 10},
#	{ name = "Garlic",  type = FoodType.VEGETABLE, combo = "Chicken",discovered = false, cost = 15, modifier = 10},
#	{ name = "Turnip",  type = FoodType.VEGETABLE, combo = "Thyme",  discovered = false, cost = 10, modifier = 5},
#	{ name = "Beans",   type = FoodType.VEGETABLE, combo = "Onion",  discovered = false, cost = 20, modifier = 15},
	{ name = "Beef",    type = FoodType.PROTEIN,   combo = "Thyme",  discovered = false, cost = 25, modifier = 20},
	{ name = "Pork",    type = FoodType.PROTEIN,   combo = "Parsley",discovered = false, cost = 30, modifier = 20},
	{ name = "Chicken", type = FoodType.PROTEIN,   combo = "Carrot", discovered = false, cost = 35, modifier = 20},
#	{ name = "Fish",    type = FoodType.PROTEIN,   combo = "Dill",   discovered = false, cost = 55, modifier = 20},
	{ name = "Thyme",   type = FoodType.HERB,      combo = "Chicken",discovered = false, cost = 50, modifier = 20},
	{ name = "Parsley", type = FoodType.HERB,      combo = "Beef", discovered = false, cost = 60, modifier = 40},
	{ name = "Dill",    type = FoodType.HERB,      combo = "Fish",   discovered = false, cost = 55, modifier = 30},
#	{ name = "Salt",    type = FoodType.HERB,      combo = "",       discovered = false, cost = 50, modifier = 50},
#	{ name = "Pepper",  type = FoodType.HERB,      combo = "",       discovered = false, cost = 50, modifier = 50}
]

var stories = [
	["A new beginning", "As the new Tender of the village perpetual stew it will be your job to make sure it stays tasty and keeps the folk around fed! 

Use this cookbook belonging to the old Stew Tender to familiarize yourself with your ingreedients and the locals. 

Good luck!"],
["The Forgotten Legacy", "As the last villager succumbs to starvation, the once-thriving medieval village fades into obscurity, its existence forever erased from the annals of history. 
The land that once teemed with life now stands as a haunting reminder of the consequences of neglect and mismanagement. 
The spirits of the villagers linger, their whispers carried on the wind, a reminder of the forgotten legacy of a village that lost its fight for survival." ],
["A Grim Reminder", "Word spreads of the abandoned village, its desolation becoming a cautionary tale for neighboring towns and kingdoms. 
The empty homes stand as a chilling reminder of the consequences of greed and incompetence. 
The villagers' plight becomes a subject of folklore, a grim tale shared around campfires, reminding generations to come of the fragility of life and the importance of communal support."],
["Rebirth from Ashes", "As the village falls into ruin, its story catches the attention of a wandering group of benevolent travelers. 
Filled with compassion, they gather the strength to rebuild the village, striving to create a brighter future. 
The once-starved land becomes a symbol of resilience and redemption, as the village transforms into a flourishing community, nurturing life and prosperity. 
The memory of the famine remains, but the villagers' tenacity prevails, offering hope to others facing similar challenges."]
]

var comboPrev = ""
var combo = 1
func calculateCombo(itemName):
	if (comboPrev != ""):
		var newCombo = false
		for food in foodLibrary:
			if food.name == comboPrev && food.combo == itemName && !food.discovered:
				food.discovered = true
				$/root/Main/bookRecipOpen.revealCombo(comboPrev)
				comboPrev = itemName
				combo += 1
				newCombo = true
		if !newCombo:
			comboPrev = itemName
			combo = 1
	else:
		comboPrev = itemName
		combo = 1

func combofy(foodItem):
	var modifier = 0
	for i in foodLibrary:
		if i.name == foodItem.name:
			modifier = combo * i.modifier
	foodItem.ttl -= modifier
	foodItem.stats.filling += modifier
	foodItem.stats.power += modifier
	foodItem.stats.taste += modifier
	return foodItem

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	$/root/Main/HUD.visible = false	

func startGame():
	#clear values
	Score = 0
	Money = 0
	MoneyToday = 0
	FoodItems.clear()
	Population.clear()
	Orders.clear()
	ToBePopulated.clear()
	Rip.clear()
	#init game
	setupFoodItems()
	setupPopulation(Population)
	Population.shuffle()
	$/root/Main.startGame()
	$/root/Main.updateLabels()
	$/root/Main/HUD.visible = true
	$/root/Main/bookRecipOpen/page3/Gameover.visible = false
	$/root/Main/bookRecipOpen.startGame()
	$/root/Main/bookRecipOpen.setPageRec()
	gameState = gameStateType.START

func endGame():
	updateHighscore()
	updateStory()
	$/root/Main/bookRecipOpen/page3/Gameover.visible = true
	$/root/Main/HUD.visible = false
	$/root/Main/bookRecipOpen.endGame()
	$/root/Main/bookRecipOpen.setPageMenu()
	gameState = gameStateType.END
	
func updateHighscore():
	var highScoreNode = $/root/Main/bookRecipOpen/page3/Highscore
	var highScore = int(highScoreNode.text.split(" ")[1])
	if highScore < Score:
		highScoreNode.text = highScoreNode.text.split(" ")[0] + " " + str(Score)

func updateStory():
	var storyHeaderNode = $/root/Main/bookRecipOpen/page3/StoryHeader
	var storyBodyNode = $/root/Main/bookRecipOpen/page3/Story
	var story = rng.randi_range(1,3)
	var storyHeaderText = stories[story][0]
	var storyBodyText = stories[story][1]
	storyHeaderNode.text = storyHeaderText
	storyBodyNode.text = storyBodyText

func _process(_delta):
	pass

func degradeSoupItems(damage):
	for foodItem in FoodItems:
		if (foodItem.inSoup):
			foodItem.ttl -= damage
		if (foodItem.ttl <= 0):
			FoodItems.erase(foodItem)

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
	$/root/Main.updateLabels()

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

func getTexture(itemname):
	return "res://Assets/Soup/items/" + itemname.to_lower() + "1.png"

func getFoodItem(itemName = "", stats: FoodStats = null):
	var item = getRandomItem() if itemName == "" else getFoodFromLibrary(itemName) #TODO: can crash here if we dont find name in lib
	var i = FoodItem.new()
	i.name = item.name
	i.type = item.type
	i.ttl = rng.randf_range(60, 120)
	i.hiddenCombo = item.combo
	i.inSoup = false
	var itemStats = FoodStats.new()
	itemStats.filling = stats.filling if stats != null else getFilling(item)
	itemStats.power = stats.power if stats != null else getPower(item)
	itemStats.taste = stats.taste if stats != null else getTaste(item)
	i.stats = itemStats
	return i
	
func getRandomItem():
	return foodLibrary.pick_random()
	
func getFoodFromLibrary(foodName):
	for item in foodLibrary:
		if foodName == item.name: return item
	return null

func getFilling(item):
	if (item.type == FoodType.VEGETABLE):
		return rng.randi_range(5, 14)
	if (item.type == FoodType.PROTEIN):
		return rng.randi_range(3, 9)
	if (item.type == FoodType.HERB):
		return rng.randi_range(0, 2)

func getPower(item):
	if (item.type == FoodType.VEGETABLE):
		return rng.randi_range(3, 10)
	if (item.type == FoodType.PROTEIN):
		return rng.randi_range(8, 15)
	if (item.type == FoodType.HERB):
		return rng.randi_range(0, 2)

func getTaste(item):
	if (item.type == FoodType.VEGETABLE):
		return rng.randi_range(0, 5)
	if (item.type == FoodType.PROTEIN):
		return rng.randi_range(0, 5)
	if (item.type == FoodType.HERB):
		return rng.randi_range(15, 30)

func checkMoneyShop():
	$/root/Main/bookBuyOpen.checkMoney()

func orderItem(foodName, cost):
	if (Money < cost): return
	Money -= cost
	$/root/Main.updateLabels()
	var deliveryGuy = Human.new()
	deliveryGuy.name = "Karl-Bertil"
	deliveryGuy.status = Rank.PEASANT
	deliveryGuy.foodType = FoodType.VEGETABLE
	deliveryGuy.holdingBowl = false
	deliveryGuy.holdingBox = true
	deliveryGuy.hunger = Hunger.CONTEMPT
	deliveryGuy.fat = false
	for i in range(rng.randi_range(1,3)):
		var foodItem = getFoodItem(foodName)
		FoodItems.append(foodItem)
		deliveryGuy.boxContent.append(foodItem)
	Orders.append(deliveryGuy)
	checkMoneyShop()

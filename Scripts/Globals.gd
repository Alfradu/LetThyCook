extends Node

enum handState { OPEN, CLOSED }
enum FoodType { VEGETABLE = 0, PROTEIN = 1, HERB = 2 }
enum Rank { PEASANT = 0, SOLDIER = 1, NOBLE = 2 }
enum Hunger { ALMOSTDEAD, HUNGRY, CONTEMPT, FULL }
enum HumanState { IDLE, WALKING_TO_CAULDRON, TAKING, WALKING_TO_END, DONE }
enum TimeOfDay { MORNING, DAY, NIGHT }
enum cauldronState { UNEATABLE = 0, BAD = 1, PRETTYGOOD = 2, AMAZING = 3}

@export var SOUPSTATS = {
	filling = 0,
	power = 0,
	taste = 0,
	umami = 0
}

@export var FoodItems = []
@export var Population = []
var ToBePopulated = []

var soupLevel

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
	var isDead: bool
	var hunger: Hunger
	var satisfaction: int
	
	func humandideat():
		var partOfSoupWithpreference = 0
		var itemsInSoup = 0
		for item in Globals.FoodItems:
			if item.inSoup:
				itemsInSoup += 1
				if item.type == foodType:
					partOfSoupWithpreference += 1
		partOfSoupWithpreference /= itemsInSoup if itemsInSoup > 0 else 1

		self.satisfaction = (Globals.SOUPSTATS.filling + Globals.SOUPSTATS.power + Globals.SOUPSTATS.taste) / 3 + (40 * partOfSoupWithpreference)
		self.hunger += 2 
	
	func degradehuman():
		self.hunger -= 1
		if hunger <= 0:
			isDead = true
	
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

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

extends Node

enum handState { OPEN, CLOSED }
enum FoodType { VEGETABLE = 0, PROTEIN = 1, HERB = 2 }
enum Rank { PEASANT, SOLDIER, NOBLE }
enum Hunger { ALMOSTDEAD, HUNGRY, CONTEMPT, FULL }
enum HumanState { IDLE, WALKING_TO_CAULDRON, TAKING, WALKING_TO_END, DONE }

@export var SOUPSTATS = {
	filling = 0,
	power = 0,
	taste = 0
}

@export var FoodItems = []
@export var Population = []

var soupLevel
var soupState

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
	var holdingBowl: bool
	var holdingBox: bool
	var hunger: Hunger
	
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	updateLabels()

var time = 0

func _process(_delta):
	pass

func updateLabels():
	$/root/Main/Filling.value = SOUPSTATS.filling
	$/root/Main/Filling/Label.text = "Filling: %d%%" % SOUPSTATS.filling
	$/root/Main/Power.value = SOUPSTATS.power
	$/root/Main/Power/Label.text = "Power: %d%%" % SOUPSTATS.power
	$/root/Main/Taste.value = SOUPSTATS.taste
	$/root/Main/Taste/Label.text = "Taste: %d%%" % SOUPSTATS.taste

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
	
	var oldSoupState = soupState
	soupState = int(quality / 25)
	
	if oldSoupState != soupState:
		$/root/Main/cauldron.stateupdate = true

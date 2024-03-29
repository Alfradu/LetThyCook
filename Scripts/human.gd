extends Node2D

@onready var body = $Body
@onready var holding = $Holding
@onready var foodEffect = $foodEffect
@onready var bowl = load("res://Assets/People/Bowl.png")
@onready var bowlFull = load("res://Assets/People/BowlFull.png")
@onready var box = load("res://Assets/People/Box.png")
@onready var peasant = load("res://Assets/People/Peasant.png")
@onready var peasantWIDE = load("res://Assets/People/PeasantWIDE.png")
@onready var soldier = load("res://Assets/People/Soldier.png")
@onready var soldierWIDE = load("res://Assets/People/SoldierWIDE.png")
@onready var amazing = load("res://Assets/People/amazing.png")
@onready var happy = load("res://Assets/People/happy.png")
@onready var didnoteat = load("res://Assets/People/didnoteat.png")
@onready var dead = load("res://Assets/People/dead.png")
@onready var cauldron = $/root/Main/RefPoints/cauldron

var state
var targetPos
var isHovered = false
var hasEaten = false

var human

# Called when the node enters the scene tree for the first time.
func _ready():
	$Body.texture = peasant
	$Holding.texture = bowl
	targetPos = cauldron.position
	pass # Replace with function body.

func init(init_human):
	var _rng = RandomNumberGenerator.new()
	if (init_human.holdingBowl):
		holding.texture = bowl
	if (init_human.holdingBox):
		holding.texture = box
		populateBox(init_human.boxContent)
	holding.scale.x = 1
	holding.scale.y = 1
	setBodyTexture(init_human.status, init_human.fat)
	human = init_human
	state = Globals.HumanState.WALKING_TO_CAULDRON
	self.position = $/root/Main/RefPoints/humanSpawn.position

func populateBox(itemArr):
	if itemArr.size() == 1:
		var itemTexture = load(Globals.getTexture(itemArr[0].name))
		$Holding/item1.texture = itemTexture
		$Holding/item2.texture = itemTexture
		$Holding/item3.texture = itemTexture
	elif itemArr.size() == 2:
		var itemTexture = load(Globals.getTexture(itemArr[0].name))
		var itemTexture2 = load(Globals.getTexture(itemArr[1].name))
		$Holding/item1.texture = itemTexture
		$Holding/item2.texture = itemTexture2
		$Holding/item3.texture = itemTexture
	elif itemArr.size() >= 3:
		var itemTexture = load(Globals.getTexture(itemArr[0].name))
		var itemTexture2 = load(Globals.getTexture(itemArr[1].name))
		var itemTexture3 = load(Globals.getTexture(itemArr[2].name))
		$Holding/item1.texture = itemTexture
		$Holding/item2.texture = itemTexture2
		$Holding/item3.texture = itemTexture3
	else:
		var itemTexture = load(Globals.getTexture("Cabbage"))
		var itemTexture2 = load(Globals.getTexture("Beef"))
		var itemTexture3 = load(Globals.getTexture("Parsley"))
		$Holding/item1.texture = itemTexture
		$Holding/item2.texture = itemTexture2
		$Holding/item3.texture = itemTexture3
	$Holding/item1.visible = true
	$Holding/item2.visible = true
	$Holding/item3.visible = true

func setBodyTexture(status, fat):
	if (status == Globals.Rank.PEASANT):
		if fat:
			body.texture = peasantWIDE
		else:
			body.texture = peasant
	if (status == Globals.Rank.SOLDIER):
		if fat:
			body.texture = soldierWIDE
		else:
			body.texture = soldier

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (state == Globals.HumanState.WALKING_TO_CAULDRON):
		var collider = $RayCast2D.get_collider()
		if collider == null || collider.name != "humanArea":
			self.position = self.position.lerp(targetPos, delta)
		if abs(self.position.x - targetPos.x) < 10 && abs(self.position.y - targetPos.y) < 10:
			state = Globals.HumanState.TAKING
	if (state == Globals.HumanState.TAKING):
		if (human.holdingBowl):
			if (!$AnimationPlayer.is_playing()):
				$AnimationPlayer.play("dipbowl")
		if (human.holdingBox):
			if (!$AnimationPlayer.is_playing()):
				$AnimationPlayer.play("leaveCrate")
	if (state == Globals.HumanState.WALKING_TO_END):
		self.position = self.position.lerp(targetPos, delta)
		if abs(self.position.x - targetPos.x) < 40 && abs(self.position.y - targetPos.y) < 40:
			state = Globals.HumanState.DONE
	if (state == Globals.HumanState.DONE):
		if (human.holdingBowl):
			human.degradehuman()
			if(!human.isDead):
				Globals.ToBePopulated.append(human)
			queue_free()
		if (human.holdingBox):
			Globals.deliveryBoys -= 1
			queue_free()

func _input(event):
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && !Globals.bookOpen:
		if event.is_pressed() && isHovered && state == Globals.HumanState.TAKING && !hasEaten:
			$AnimationPlayer.speed_scale = 2			
			$AnimationPlayer.play_backwards("dipbowl");
			$hepunch.play()

func _on_animation_player_animation_finished(anim_name):
	if (anim_name == "dipbowl" or anim_name == "leaveCrate"):
		targetPos = $/root/Main/RefPoints/humanEnd.position
		state = Globals.HumanState.WALKING_TO_END
		if (anim_name == "dipbowl"):
			foodEffect.texture = getEffectTexture(human.satisfaction)
			var score = 100 * (human.status + 1) + human.satisfaction
			var money = (50 + human.satisfaction) * human.status
			self.get_node("foodEffect/ScoreEarned").text = str(score)
			self.get_node("foodEffect/MoneyEarned").text = ("$" + str(money)) if money != 0 else ""
			$AnimationPlayer.play("react")
			$heate.play()
			$hewalk.play()
			Globals.Score += score
			Globals.Money += money
			Globals.MoneyToday += money
			Globals.checkMoneyShop()
			
		
func getEffectTexture(satisfaction):
	if satisfaction > 100:
		return amazing
	if satisfaction > 20:
		return happy
	else:
		return didnoteat

func eat():
	human.humandideat()
	$hefill.play()
	if Globals.soupLevel != Globals.cauldronLevels.EMPTY: holding.texture = bowlFull
	hasEaten = true
	
func leftBox():
	human.satisfaction = 0
	$Holding.onTable = true
	$Holding.items = human.boxContent
	$Holding.reparent($/root/Main/ItemContainer)

func _on_bowl_hit_box_area_entered(area):
	if area.name == "HandCollision":
		isHovered = true
		if $/root/Main/hand.state == Globals.handState.CLOSED && state == Globals.HumanState.TAKING && !hasEaten && human.holdingBowl && !human.holdingBox:
			$AnimationPlayer.speed_scale = 2
			$AnimationPlayer.play_backwards("dipbowl")
			$hepunch.play()

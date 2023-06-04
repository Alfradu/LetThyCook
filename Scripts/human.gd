extends Node2D

@onready var body = $Body
@onready var holding = $Holding
@onready var bowl = load("res://Assets/People/Bowl.png")
@onready var box = load("res://Assets/People/Box.png")
@onready var peasant = load("res://Assets/People/Peasant.png")
@onready var soldier = load("res://Assets/People/Soldier.png")
@onready var cauldron = $/root/Main/RefPoints/cauldron

var state
var targetPos
var isHovered = false

var human

# Called when the node enters the scene tree for the first time.
func _ready():
	$Body.texture = peasant
	$Holding.texture = bowl
	targetPos = cauldron.position
	pass # Replace with function body.

func init(init_human):
	var rng = RandomNumberGenerator.new()
	if (init_human.holdingBowl):
		holding.texture = bowl
		holding.scale.x = 1
		holding.scale.y = 1
	if (init_human.holdingBox):
		holding.texture = box
	setBodyTexture(init_human.status)
	human = init_human
	state = Globals.HumanState.WALKING_TO_CAULDRON
	self.position = $/root/Main/RefPoints/humanSpawn.position

func setBodyTexture(status):
	if (status == Globals.Rank.PEASANT):
		body.texture = peasant
	if (status == Globals.Rank.SOLDIER):
		body.texture = soldier		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Label.text = str(human.satisfaction)
	if (state == Globals.HumanState.WALKING_TO_CAULDRON):
		var collider = $RayCast2D.get_collider()
		if collider == null || collider.name != "humanArea":
			self.position = self.position.lerp(targetPos, delta)
		if abs(self.position.x - targetPos.x) < 10 && abs(self.position.y - targetPos.y) < 10:
			state = Globals.HumanState.TAKING
	if (state == Globals.HumanState.TAKING):
		if (!$AnimationPlayer.is_playing()):
			$AnimationPlayer.play("dipbowl")
	if (state == Globals.HumanState.WALKING_TO_END):
		self.position = self.position.lerp(targetPos, delta)
		if self.position == targetPos:
			state = Globals.HumanState.DONE
	if (state == Globals.HumanState.DONE):
		human.degradehuman()
		if(!human.isDead):
			Globals.ToBePopulated.append(human)
		queue_free()

func _input(event):
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed() && isHovered && state == Globals.HumanState.TAKING:
			$AnimationPlayer.play_backwards("dipbowl");
		
func _on_area_2d_area_entered(area):
	if area.name == "HandCollision":
		isHovered = true
		print($/root/Main/hand.state)
		if $/root/Main/hand.state == Globals.handState.CLOSED && state == Globals.HumanState.TAKING:
			$AnimationPlayer.play_backwards("dipbowl");

func _on_area_2d_area_exited(area):
	if area.name == "HandCollision":
		isHovered = false

func _on_animation_player_animation_finished(anim_name):
	if (anim_name == "dipbowl"):
		state = Globals.HumanState.WALKING_TO_END
		targetPos = $/root/Main/RefPoints/humanEnd.position
		
func eat():
	human.humandideat()

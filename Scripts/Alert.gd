extends Node2D

var ttl = 3
# Called when the node enters the scene tree for the first time.
func _ready():
	ttl = 3

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	ttl -= delta
	if ttl < 0:
		$AnimationPlayer.play("begone")

func _on_animation_player_animation_finished(_anim_name):
	queue_free()

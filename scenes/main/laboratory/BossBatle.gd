extends Area2D

var start = true

func _ready():
	pass


func _on_BossBatle_body_entered(body):
	
	if body.is_in_group("player") and start:
		$TentacleWall/AnimationPlayer.play("start")
		$Boss.show()
		
	start = false
	
	
func _on_AnimationPlayer_animation_finished(anim_name):
	
	if anim_name == "start":
		$TentacleWall/AnimationPlayer.play("idle")

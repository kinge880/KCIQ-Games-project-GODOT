extends Control

var is_paused = false

func _ready():
	pass


#pausa o jogo com a tecla esc
func _input(event):
	
	if Input.is_action_just_pressed("Inventory") and not is_paused and not ui_global.ui_active:
		$Inventory.show()
		$Background.show()
		get_tree().paused = true
		is_paused = true
		ui_global.ui_active = true
		$AnimationPlayer.play("enter")
		
	elif Input.is_action_just_pressed("Inventory") and is_paused and $AnimationPlayer.current_animation != "exit":
		$AnimationPlayer.play("exit")

func _on_AnimationPlayer_animation_finished(anim_name):
	
	if anim_name == "exit":
		$Inventory.hide()
		$Background.hide()
		get_tree().paused = false
		is_paused = false
		ui_global.ui_active = false

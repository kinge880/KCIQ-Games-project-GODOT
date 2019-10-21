extends Control

onready var button = $Panel/ButtonContinue

var is_paused = false

func _ready():
	pass


#pausa o jogo com a tecla esc
func _input(event):
	
	if Input.is_action_just_pressed("esc") and not is_paused and not ui_global.ui_active:
		$Panel.show()
		$BlurBackgroundShader.show()
		get_tree().paused = true
		is_paused = true
		ui_global.ui_active = true
		button.grab_focus()
		$AnimationPlayer.play("enter")


#fecha o menu de pause e despausa o jogo
func _on_ButtonContinue_pressed():
	
	if $AnimationPlayer.current_animation != "exit":
		$AnimationPlayer.play("exit")


#Futuramente deve abrir o painel de opções
func _on_ButtonOptions_pressed():
	
	if $AnimationPlayer.current_animation != "exit":
		$AnimationPlayer.play("exit")


func _on_AnimationPlayer_animation_finished(anim_name):
	
	if anim_name == "exit":
		$Panel.hide()
		$BlurBackgroundShader.hide()
		get_tree().paused = false
		is_paused = false
		ui_global.ui_active = false

#sai do jogo ou volta ao menu principal
func _on_ButtonExit_pressed():
	
	$Panel.hide()
	$PopupExit.show()
	$PopupExit/ButtonNot.grab_focus()


#Se o player clicar em sim ele sai do jogo
func _on_ButtonYes_pressed():
	
	get_tree().quit()


#Se o player clicar em não ele volta ao menu anterior
func _on_ButtonNot_pressed():
	
	$Panel.show()
	$PopupExit.hide()
	$Panel/ButtonContinue.grab_focus()
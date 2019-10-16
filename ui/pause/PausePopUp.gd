extends CanvasLayer

var is_paused = false
var is_paused_by_esc = false

func _ready():
	pass
	
#pausa o jogo com a tecla esc
func _input(event):
	if Input.is_action_just_pressed("esc") and is_paused == true:
		$Label.hide()
		$BlurBackgroundShader.hide()
		get_tree().paused = false
		is_paused = false
		is_paused_by_esc = false
		
	elif Input.is_action_just_pressed("esc") and is_paused == false:
		$Label.show()
		$BlurBackgroundShader.show()
		get_tree().paused = true
		is_paused = true
		is_paused_by_esc = true
"""
#pausa o jogo ao minimizar a tela
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_FOCUS_IN:
		if is_paused_by_esc:
			return
		else:
			get_tree().paused = false
	elif what == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
		if is_paused_by_esc:
			return
		else:
			get_tree().paused = true
"""
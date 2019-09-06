extends CanvasLayer

onready var life = $Margin/HBoxContainer/Recipe/LifeBar
onready var stamina = $Margin/HBoxContainer/Recipe/StaminaBar
onready var power_cristal = $Margin/HBoxContainer/EnergyFragments
onready var tween = $Tween

func _update_lifeBar(new_life):
	
	tween.interpolate_property(life, "value", life.value, new_life, 0.6, Tween.TRANS_LINEAR, Tween.EASE_IN)
	
	if not tween.is_active():
		tween.start()
		
	$AnimationPlayer.play("lifeBar_flash")


func _update_staminaBar(new_stamina):
	
	tween.interpolate_property(stamina, "value", stamina.value, new_stamina, 0.6, Tween.TRANS_LINEAR, Tween.EASE_IN)
	
	if not tween.is_active():
		tween.start()


func _update_cristal_number(new_cristal_number):
	power_cristal.text = String(new_cristal_number)


func _on_Player_life_changed(life):
	_update_lifeBar(life)


func _on_Player_stamina_changed(stamina):
	_update_staminaBar(stamina)


func _on_AnimationPlayer_animation_finished(anim_name):
	
	if anim_name == 'lifeBar_flash':
		life.tint_progress = Color(1, 0, 0)


func _on_Player_energy_changed(stamina):
	_update_staminaBar(stamina)


func _on_Player_power_crystal_changed(cristal_number):
	_update_cristal_number(cristal_number)

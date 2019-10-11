extends CanvasLayer

onready var life_bar = $Margin/BoxGeneral/Recipe/LifeHbox/LifeBar
onready var stamina_bar = $Margin/BoxGeneral/Recipe/StaminaHbox/StaminaBar
onready var life = $Margin/BoxGeneral/Recipe/LifeHbox/Life
onready var stamina = $Margin/BoxGeneral/Recipe/StaminaHbox/Stamina
onready var power_cristal = $Margin/BoxGeneral/VBoxContainer/EnergyFragments
onready var hability = $Margin/BoxGeneral/VBoxContainer/Hability

onready var tween = $Tween

func _update_lifeBar(new_life_porcent, actual_life):
	
	tween.interpolate_property(life_bar, "value", life_bar.value, new_life_porcent, 0.6, Tween.TRANS_LINEAR, Tween.EASE_IN)
	life.text = String(actual_life)
	
	if not tween.is_active():
		tween.start()
		
	$AnimationPlayer.play("lifeBar_flash")


func _update_staminaBar(new_stamina_porcent, actual_stamina):
	
	tween.interpolate_property(stamina_bar, "value", stamina_bar.value, new_stamina_porcent, 0.6, Tween.TRANS_LINEAR, Tween.EASE_IN)
	stamina.text = String(actual_stamina)
	
	if not tween.is_active():
		tween.start()


func _update_cristal_number(new_cristal_number):
	power_cristal.text = String(new_cristal_number)


func _on_Player_hability_changed(new_hability):
	hability.text = String(new_hability)


func _on_Player_life_changed(life_porcent, life):
	_update_lifeBar(life_porcent, life)


func _on_Player_stamina_changed(stamina_porcent, stamina):
	_update_staminaBar(stamina_porcent, stamina)


func _on_AnimationPlayer_animation_finished(anim_name):
	
	if anim_name == 'lifeBar_flash':
		life_bar.tint_progress = Color(1, 0, 0)


func _on_Player_energy_changed(stamina_porcent, stamina):
	_update_staminaBar(stamina_porcent, stamina)


func _on_Player_power_crystal_changed(cristal_number):
	_update_cristal_number(cristal_number)
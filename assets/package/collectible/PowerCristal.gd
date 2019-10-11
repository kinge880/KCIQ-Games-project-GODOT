extends Area2D
onready var crystal = $"../"
onready var force_life_time = $"../ForcerLifeTime"
export (int) var crystal_value

func _ready():
	
	#randomiza a forma aplicada sobre x no cristal criado, permitindo um efeito mais dahora
	#também randomiza o valor de cada cristal, indo de 1 a 4
	randomize()
	crystal.applied_force.x =  rand_range(-400, 400)
	crystal.applied_force.y = -1100
	force_life_time.start()


#apaga o cristal após o player pegar ele
func _on_PowerCristalArea_body_entered(body):
	
	if body.name == "Player":
		if body.has_method("collect_power_crystal"):
			body.collect_power_crystal(crystal_value)
			$"../".queue_free()


#retorna a força a 0 depois de alguns segundos para fazer um efeito de queda
func _on_ForcerLifeTime_timeout():
	
	crystal.applied_force.x = 0
	crystal.applied_force.y = 0

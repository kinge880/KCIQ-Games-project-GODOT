extends Area2D

#Nome da habilidade, deve ser escrito igual a como está no player
export (String) var hability_name
#esse boolean define se é uma habilidade secundaria, como fast_time, ou uma mecanica de exploração
#se for verdadeiro é uma habilidade, se for falso é uma mecanica como double_jump
export (bool) var is_active_hability


func _on_hability_actor_body_entered(body):
	
	#se o corpo estiver no grupo "player"
	if body.is_in_group("player"):
		
		#se for uma habilidade
		if is_active_hability:
			if not PlayerGlobalsVariables.hability.has(hability_name):
				PlayerGlobalsVariables.hability.append(hability_name)
				body.att_hability()
		#se for uma mecanica
		else:
			PlayerGlobalsVariables.get_hability(hability_name)
		
		queue_free()
		
func pause():
	
	get_tree().paused = true

func _on_HabilityActor_body_exited(body):
	
	pass

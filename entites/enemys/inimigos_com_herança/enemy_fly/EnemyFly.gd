extends "res://entites/enemys/inimigos_com_herança/actors.gd"

func _ready():

	add_to_group("enemies")
	
	max_life = 10
	current_life = 10
	damage = 10
	damage_force = 150
	walk_speed = 50


# função para capturar a direção do enemy
func update_velocity():
	
	move_and_slide(to_player * walk_speed)


# estado standing
func standing(delta):
	
	if player:
		state = State.WALK
	elif velocity.x == 0:
		animation.play("idle")


#função que ativa o movimento, pegando a posição do player enquanto ele tiver na visão
func walking(delta):
	
	player_overlapse()
	if player:
		to_player = player.global_position - global_position
		#print(to_player)
		to_player = to_player.normalized()
		move_and_slide(to_player * walk_speed)
		
		if to_player.x < 0:
			animation.play("walk_left")
		elif to_player.x > 0:
			animation.play("walk_rigth")
		
		if dash_zone and $Timers/DashDelay.time_left == 0:
			$Timers/DashDuration.start()
			state = State.ATTACK
	else:
		state = State.STANDING


#função que ativa o ataque a cada 5 segundos
func attack(delta):
	
	if $Timers/DashDuration.time_left > 1:
		dash_direction = player.global_position - global_position
		modulate = Color.yellow
		animation.play("pre_dash")
	elif $Timers/DashDuration.time_left > 0:
		animation.play("dash")
		move_and_slide(dash_direction.normalized() * walk_speed * 8)
	else:
		standing_after_damage_transition()
	
	player_overlapse()


#após terminar o ataque para por alguns segundos
func standing_after_damage():
	 
	modulate = Color.white
	
	if delay_after_damage.time_left == 0:
		state = State.STANDING
	elif velocity.x == 0:
		animation.play("idle")


#transição após o ataque
func standing_after_damage_transition():
	$Timers/DashDelay.start()
	delay_after_damage.start()
	state = State.DELAY_AFTER_DAMAGE


func _on_HitBox_body_entered(body):
	
	_on_HitBox_body_entered_father(body)


func _on_HitBox_body_exited(body):
	
	_on_HitBox_body_exited_father(body)


func _on_AnimationEnemy_animation_finished(anim_name):
	
	_on_AnimationEnemy_animation_finished_father(anim_name)


func _on_HitBox_area_entered(area):
	
	_on_HitBox_area_entered_father(area)


func _on_HitBox_area_exited(area):
	
	_on_HitBox_area_exited_father(area)


func _on_VisionPlayer_body_entered(body):
	
	_on_VisionPlayer_body_entered_father(body)


func _on_VisionPlayer_body_exited(body):
	
	_on_VisionPlayer_body_exited_father(body)


func _on_DashZone_body_entered(body):
	
	_on_DashZone_body_entered_father(body)


func _on_DashZone_body_exited(body):
	
	_on_DashZone_body_exited_father(body)
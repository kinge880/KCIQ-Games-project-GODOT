extends "res://entites/enemys/inimigos_com_herança/actors.gd"

onready var navigation = $"../../Navigation2D"

func _ready():

	add_to_group("enemies")
	
	max_life = 10
	current_life = 10
	damage = 10
	damage_force = 150
	walk_speed = 50
	gravity = 100

# função para capturar a direção do enemy
func update_velocity():
	
	move_and_slide(to_player * walk_speed)


# estado standing
func standing(delta):
	
	if player:
		state = State.WALK
	elif save_player:
		if vision_player.overlaps_body(save_player):
			player = save_player
			state = State.WALK
	
	animation.play("idle")


#função que ativa o movimento, pegando a posição do player enquanto ele tiver na visão
func walking(delta):
	
	player_overlapse()
	if player:
		
		#pega um path de navegação para o enemy (precisa ser melhorado ainda)
		var path_navigation = navigation.get_simple_path(global_position, player.global_position, false)
		#caso o path venha vazio ele muda a forma de pegar posição, necessario para evitar qualquer tipo de problema inesperado
		if path_navigation:
			var nextPos = path_navigation[1]
			to_player = nextPos - global_position
		else:
			to_player = player.global_position - global_position
		
		to_player = to_player.normalized()
		move_and_slide(to_player * walk_speed)
		dash_direction = player.global_position - global_position
		
		if to_player.x < 0:
			animation.play("walk_left")
		elif to_player.x > 0:
			animation.play("walk_rigth")
		
		#quando o delay do dash for 0, inicia o dash
		if dash_zone and $Timers/DashDelay.time_left == 0:
			$Timers/DashDuration.start()
			state = State.ATTACK
	else:
		state = State.STANDING


#função que ativa o ataque a cada 5 segundos
func attack(delta):
	
	#primeiro ativa um pre ataque, para o player perceber que o inimigo vai ar
	if $Timers/DashDuration.time_left > 0.5:
		if player:
			dash_direction = player.global_position - global_position
		modulate = Color.yellow
		animation.play("pre_dash")
	#ativa o ataque e move o enemy
	elif $Timers/DashDuration.time_left > 0:
		animation.play("dash")
		move_and_slide(dash_direction.normalized() * walk_speed * 8)
	else:
		standing_after_damage_transition()
	
	player_overlapse()


#após terminar o ataque para por alguns segundos
func standing_after_damage():
	
	modulate = Color.white
	animation.play("idle")
	
	if delay_after_damage.time_left == 0:
		state = State.STANDING


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
extends "res://entites/enemys/inimigos_com_herança/actors.gd"

func _ready():
	
	add_to_group("enemies")
	start_position = position
	end_position = start_position + Vector2(move_distance,0)


# estado standing, esse estado mantem o movimento basico e parado, além de ativar estados de ataque (caso tenha)
func standing(delta):
	
	if is_on_floor() and delay_jump.time_left != 0:
		velocity.x = 0
		animation.play("idle")
	if is_on_floor() and delay_jump.time_left == 0:
		#vira o enemy caso chegue a posição final ou inicial
		if position.x >= end_position.x:
		
			direction = -1
			platform_drop.position.x = -15.733
			sprite.flip_h = false
			platform_wall.cast_to.x = -14
		elif position.x <= start_position.x:
		
			direction = 1
			platform_drop.position.x = 15.733
			sprite.flip_h = true
			platform_wall.cast_to.x = 14
				
		velocity.y = jump_speed
		delay_jump.start()
	
	elif not is_on_floor():
		#vira o enemy caso chegue a um abismo ou bata na parede
		if not platform_drop.is_colliding() or platform_wall.is_colliding():
			direction *= -1
			platform_drop.position.x *= -1
			
			if direction > 0:
				sprite.flip_h = true
				platform_wall.cast_to.x = 14
			else:
				sprite.flip_h = false
				platform_wall.cast_to.x = -14
				
		velocity.x = walk_speed * direction
		animation.play("walk")


	player_overlapse()
	velocity.y += gravity * delta
	velocity.normalized()
	velocity = move_and_slide(velocity, Vector2.UP)

#a função de dano foi posta aqui para permitir adicionar gravidade, já que os voadores não tem a gravidade
func damage(delta):
	
	#ativa as animações de dano e bota uma gravidade
	animation_effets.play("take_damage")
	animation.play("hurt")
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)

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

func _on_DelayDrop_timeout():
	
	Drop_timeout()

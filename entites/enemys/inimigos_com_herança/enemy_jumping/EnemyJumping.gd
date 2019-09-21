extends "res://entites/enemys/inimigos_com_herança/actors.gd"

func _ready():

	add_to_group("enemies")
	
	max_life = 10
	current_life = 10
	damage = 10
	damage_force = 140
	walk_speed = 150
	jump_speed = -200
	gravity = 400


#função que inicia o movimento de pulo assim que o timer chega a 0
func update_velocity():
	
	if delay_move.time_left == 0:
		
		#esse if auxilia para sincronizar os times no inicio do movimento
		if move_start == true:
			move_start = false
			move_distance.start()
			
		move_time.start()
		state = State.JUMPING


#estado onde o enemy fica parado pór alguns segundos após cada movimento
func standing(delta):
	
	velocity.x = 0
	animation.play("idle")
	#quando o timer chegar a 0 troca esse estado pelo estado de pulo
	update_velocity()
	player_overlapse()
	velocity.y += gravity * delta
	velocity = move_and_slide_with_snap(velocity, SNAP, Vector2.UP, true, 4, deg2rad(46), true)
	
	if move_distance.time_left == 0:
		
		move_distance.start()
		direction *= -1
		platform_drop.position.x *= -1
		
		if direction > 0:
			sprite.flip_h = true
		else:
			sprite.flip_h = false


#estado de pulo
func jump(delta):
	
	#quando o timer do movimento chegar a 0 volta ao estado parado
	if move_time.time_left == 0:
		delay_move.start()
		state = State.STANDING
		
	if is_on_floor():
		velocity.y = jump_speed
	
	player_overlapse()
	animation.play("walk")
	velocity.x = walk_speed * direction
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	
	if move_distance.time_left == 0:
		
		move_distance.start()
		direction *= -1
		platform_drop.position.x *= -1
		
		if direction > 0:
			sprite.flip_h = true
		else:
			sprite.flip_h = false


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
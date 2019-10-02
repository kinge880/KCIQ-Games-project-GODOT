extends "res://entites/enemys/inimigos_com_herança/actors.gd"

func _ready():
	
	state = null
	add_to_group("enemies")
	start_position = position
	end_position = start_position + Vector2(move_distance,0)
	
# estado standing
func standing(delta):
	
	# verifica se o enemy ta parado ou andando
	if velocity.x == 0:
		animation.play("idle")
	else:
		animation.play("walk")
	
	player_overlapse()
	velocity.x = walk_speed * direction
	velocity.y += gravity * delta
	velocity.normalized()
	velocity = move_and_slide_with_snap(velocity, SNAP, Vector2.UP, true, 4, deg2rad(46), true)
	
	if platform_wall.is_colliding() or not platform_drop.is_colliding():
		
		direction *= -1
		platform_drop.position.x *= -1
		
		if direction > 0:
			sprite.flip_h = true
			platform_wall.cast_to.x = 14
		else:
			sprite.flip_h = false
			platform_wall.cast_to.x = -14
	elif position.x >= end_position.x:
		
		direction = -1
		platform_drop.position.x = -15.733
		sprite.flip_h = false
		platform_wall.cast_to.x = -14
	elif position.x <= start_position.x:
		
		direction = 1
		platform_drop.position.x = 15.733
		sprite.flip_h = true
		platform_wall.cast_to.x = 14


func fall(delta):
	
	if delay_fall.time_left == 0:
		sprite.rotation_degrees = 0
		velocity.y += gravity * delta
		velocity = move_and_slide(velocity, Vector2.UP)
	else:
		animation.play("Pre_fall")
	
	if $FallCast.is_colliding():
		state = State.STANDING


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

func _on_FallColision_body_entered(body):
	
	$FallColision.queue_free()
	delay_fall.start()
	state = State.FALL
	

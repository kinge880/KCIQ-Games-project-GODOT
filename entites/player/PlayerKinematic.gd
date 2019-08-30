extends KinematicBody2D

export var speed = 200
export var dash_multiplier = 3
export var jump_force = -250
export var lower_force = 250
export var max_life = 100
export var current_life = 100
export var double_jump_obted = true
export var jump_wall_obted = true
export var dash_obted = true
signal life_changed
var delay_after_damage = false
#var walk_right
#var walk_left
#var walk_up
#var walk_down
#var jump
#var jump_stop
#var lower_move
#var atk
var atk_delay = false
#var dash
var dash_delay = false
var air_dash = false
var atk_count = 0
var double_jump = false
var jump_wall = false
var in_ladder = false
export var gravity = 400
var gravity_aux = 0
var velocity = Vector2()
onready var sprite = $Sprite
onready var anim = $AnimationPlayer

var jumping = false

func get_input():
	pass

func _physics_process(delta):
	velocity.x = 0
	var on_wall = is_on_wall()
	#var on_wall = $ColissionWall.is_colliding()
	
	#Inputs
	#if not jump_wall and not dash_delay: 
	var walk_right = Input.is_action_pressed("ui_right")
	var walk_left = Input.is_action_pressed("ui_left") 
	var walk_up = Input.is_action_pressed("ui_up")
	var walk_down = Input.is_action_pressed("ui_down") 
	var jump = Input.is_action_just_pressed("ui_up")
	var jump_stop = Input.is_action_just_released("ui_up")
	var lower_move = Input.is_action_pressed("ui_down") 
	var dash = Input.is_action_just_pressed("ui_select")
	var atk = Input.is_action_just_pressed("ui_weak_attack")
	
	#quando tocar em uma escada
	if in_ladder:
		
		if walk_right:
			#movimento basico direita
			velocity.x = speed / 2
			sprite.flip_h = false
			anim.play("ladder")
			$ColissionWall.rotation_degrees = 270

		elif walk_left:
			#movimento basico esquerda
			velocity.x = -speed / 2
			sprite.flip_h = true
			anim.play("ladder")
			$ColissionWall.rotation_degrees = 90
		
		elif walk_up:
			#movimento basico esquerda
			velocity.y = -speed / 3
			anim.play("ladder")
			$ColissionWall.rotation_degrees = 90
		
		elif walk_down:
			#movimento basico esquerda
			velocity.y = speed / 3
			anim.play("ladder")
			$ColissionWall.rotation_degrees = 90
			
		else:
			velocity.x = 0
			velocity.y = 0
			anim.stop()
	#quando sair da escada
	else:
		#agarra na parede, desliza e se solta
		if on_wall and jump_wall_obted and lower_move and not is_on_floor():
			velocity.y += gravity * delta
			anim.play("fall")
		elif on_wall and jump_wall_obted and not is_on_floor():
			velocity.y = gravity * delta
			anim.play("jump_wall")
		else:
			#velocidade normal de queda, gravidade
			velocity.y += gravity * delta
		
		if walk_right:
			#salto na parede para a esquerda
			if on_wall and sprite.flip_h and not is_on_floor() and jump_wall_obted:
				anim.play("jump")
				velocity.x = speed * 1.5
				velocity.y = jump_force
			#movimento basico direita
			velocity.x += speed
			sprite.flip_h = false
			if is_on_floor() and not dash_delay and not atk_delay:
				anim.play("walk")
			$ColissionWall.rotation_degrees = 270
	
		if walk_left:
			#salto na parede para a direita
			if on_wall and not sprite.flip_h and not is_on_floor() and jump_wall_obted:
				anim.play("jump")
				velocity.x = -speed * 1.5
				velocity.y = jump_force
			#movimento basico esquerda
			velocity.x -= speed
			sprite.flip_h = true
			if is_on_floor() and not dash_delay and not atk_delay:
				anim.play("walk")
			$ColissionWall.rotation_degrees = 90
			
		if velocity.x == 0:
			#velocity.x = 0
			if is_on_floor() and not dash_delay and not atk_delay:
				anim.play("idle")
			
		#pulo
		if is_on_floor():
			$DoubleJumpParticle.emitting = false
			$DoubleJumpParticle2.emitting = false
			air_dash = true
			double_jump = true
			if jump:
				jumping = true
				anim.play("jump")
				velocity.y = jump_force
		elif jump_stop:
			if velocity.y < 0:
				velocity.y *= 0.5
		
		#pulo duplo
		if not on_wall and double_jump and jump and double_jump_obted and not is_on_floor():
			velocity.y = jump_force
			double_jump = false
			anim.play("double_jump")
			$DoubleJumpParticle.emitting = true
			$DoubleJumpParticle2.emitting = true
	
		#dash
		if dash and air_dash and not dash_delay and dash_obted:
			air_dash = false
			anim.play("dash")
			dash_delay = true
			speed *= dash_multiplier
			$DashTime.start()
		
		#animação de queda
		if velocity.y > 0 and not is_on_floor() and anim.current_animation != "jump_wall" and not dash_delay and not atk_delay:
			anim.play("fall")
			
		#ataque
		if atk and not is_on_floor():
			$AtkTime.start()
			atk_delay = true
			anim.play("air_atk")
		elif atk and not atk_delay:
			$AtkTime.start()
			atk_delay = true
			anim.play("atk1")
	
	if jumping and velocity.y > 0:
		jumping = false
	
	var snap = Vector2(0, 8)
	
	if jumping:
		snap = Vector2()
	
	velocity.y += gravity * delta
	
	velocity = move_and_slide_with_snap(velocity, snap, Vector2(0,-1), true, 4, deg2rad(46), true)
	
#emite o sinal que altera o valor da vida no HUD
func life_changed():
	emit_signal('life_changed', current_life)

#função que recebe o dano e reduz a vida do player
func take_damage(damage):
	if not delay_after_damage:
		current_life -= damage
		life_changed()
		delay_after_damage = true
		$DelayAfterDamageTime.start()
		$AnimationPlayer.play("take_damage")
	if current_life <=0:
		#fazer funções de morte depois
		#playback.travel("death")
		#$AnimationPlayer.play("death")
		#$DeathDelayTimer.start()
		#dead = true
		#yield($DeathDelayTimer, "timeout")
		death()

#função que ativa a condição de morte, fazer depois
func death():
	queue_free()

func _on_DelayAfterDamageTime_timeout():
	delay_after_damage = false

func _on_DashTime_timeout():
	dash_delay = false
	speed /= dash_multiplier

func _on_AtkTime_timeout():
	atk_count = 0
	atk_delay = false

func _on_ladderArea_body_entered(body):
	velocity.x = 0
	velocity.y = 0
	in_ladder = true
	gravity_aux = gravity
	gravity = 0

func _on_ladderArea_body_exited(body):
	in_ladder = false
	gravity = gravity_aux
	gravity_aux = 0

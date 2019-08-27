extends KinematicBody2D

export var speed = 200
export var dash_speed = 600
var dash_aux
export var jump_force = 250
export var lower_force = 250
export var max_life = 100
export var current_life = 100
export var double_jump_obted = true
export var jump_wall_obted = true
signal life_changed
var delay_after_damage = false
var walk_right
var walk_left
var jump
var jump_stop
var lower_move
var dash
var dash_delay = false
var air_dash = false
var double_jump = false
var jump_wall = false
export var gravity = 500
var velocity = Vector2()
onready var anim = $Sprites

func _physics_process(delta):
	var on_wall = $ColissionWall.is_colliding()
	
	#Inputs
	if not jump_wall and not dash_delay: 
	#essa variavel jump_wall impede que se possa controlar o player durante um pulo na parede, a gente faz testes depois pra definir se é melhor
	#não controlar, ou controlar o personagem durante um pulo na parede...
		walk_right = Input.is_action_pressed("ui_right")
		walk_left = Input.is_action_pressed("ui_left") 
	jump = Input.is_action_just_pressed("ui_up")
	jump_stop = Input.is_action_just_released("ui_up")
	lower_move = Input.is_action_pressed("ui_down") 
	dash = Input.is_action_just_pressed("ui_select")
	
	#agarra na parede, desliza e se solta
	if on_wall and jump_wall_obted and lower_move:
		#jump_wall = false
		velocity.y += gravity * delta
	elif on_wall and jump_wall_obted:
		#jump_wall = false
		velocity.y = gravity * delta
	else:
		#velocidade normal de queda, gravidade
		velocity.y += gravity * delta
	
	if walk_right:
		#salto na parede para a esquerda
		if on_wall and anim.flip_h and not is_on_floor() and jump_wall_obted:
			#jump_wall = true
			velocity.x = speed * 1.5
			velocity.y = -jump_force
		#movimento basico direita
		velocity.x = speed
		anim.flip_h = false
		anim.play("walk")
		$ColissionWall.rotation_degrees = 270

	elif walk_left:
		#salto na parede para a direita
		if on_wall and not anim.flip_h and not is_on_floor() and jump_wall_obted:
			#jump_wall = true
			velocity.x = -speed * 1.5
			velocity.y = -jump_force
		#movimento basico esquerda
		velocity.x = -speed
		anim.flip_h = true
		anim.play("walk")
		$ColissionWall.rotation_degrees = 90
		
	else:
		velocity.x = 0
		anim.stop()
		
	#pulo
	if is_on_floor():
		$DoubleJumpParticle.emitting = false
		$DoubleJumpParticle2.emitting = false
		#jump_wall = false
		air_dash = true
		double_jump = true
		if jump:
			velocity.y = -jump_force
	elif jump_stop and velocity.y < 0:
		velocity.y *= 0.5
	
	#pulo duplo
	if not on_wall and double_jump and jump and double_jump_obted and not is_on_floor():
		velocity.y = -jump_force
		double_jump = false
		$DoubleJumpParticle.emitting = true
		$DoubleJumpParticle2.emitting = true

	#dash
	if dash and air_dash and not dash_delay:
		air_dash = false
		dash_delay = true
		dash()
	
	velocity = move_and_slide(velocity, Vector2(0,-1))
	print($DashTime.time_left)
#funcao do dash
func dash():
	$DashTime.start()
	dash_aux = dash_speed
	dash_speed = speed
	speed = dash_aux

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
	dash_aux = dash_speed
	dash_speed = speed
	speed = dash_aux
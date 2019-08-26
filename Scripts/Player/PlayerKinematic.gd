extends KinematicBody2D

export var speed = 200
export var jump_force = 250
export var lower_force = 250
var walk_right
var walk_left
var jump
var jump_stop
var lower_move
var double_jump = false
export var double_jump_obted = true
export var jump_wall_obted = true
var jump_wall = false
export var gravity = 500
var velocity = Vector2()
onready var anim = $Sprites

func _physics_process(delta):
	var on_wall = $ColissionWall.is_colliding()
	
	#Inputs
	if not jump_wall: 
	#essa variavel jump_wall impede que se possa controlar o player durante um pulo na parede, a gente faz testes depois pra definir se é melhor
	#não controlar, ou controlar o personagem durante um pulo na parede...
		walk_right = Input.is_action_pressed("ui_right")
		walk_left = Input.is_action_pressed("ui_left") 
	jump = Input.is_action_just_pressed("ui_up")
	jump_stop = Input.is_action_just_released("ui_up")
	lower_move = Input.is_action_pressed("ui_down") 
	
	#agarra na parede, desliza e se solta
	if on_wall and jump_wall_obted and lower_move:
		jump_wall = false
		velocity.y += gravity * delta
	elif on_wall and jump_wall_obted:
		jump_wall = false
		velocity.y = gravity * delta
	#velocidade normal de queda, gravidade
	else:
		velocity.y += gravity * delta
	
	if walk_right:
		#salto na parede para a esquerda
		if on_wall and anim.flip_h and not is_on_floor() and jump_wall_obted:
			jump_wall = true
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
			jump_wall = true
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
		jump_wall = false
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
	
	velocity = move_and_slide(velocity, Vector2(0,-1))
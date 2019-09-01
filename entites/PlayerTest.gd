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
var atk_delay = false
var dash_delay = false
var dash_time_delay = false
var air_dash = false
var atk_count = 0
var double_jump = false
var jump_wall = false
var in_ladder = false
export var gravity = 800
var velocity = Vector2()
onready var sprite = $Sprite
onready var anim = $AnimationPlayer
var walk_right
var walk_left
var walk_up 
var walk_down
var jump
var jump_stop
var lower_move
var dash
var atk
var jumping = false
var on_wall

func _ready(): 
	emit_signal('life_changed', current_life * (100/max_life))

func apply_gravity(delta):
		velocity.y += gravity * delta 

func apply_move_and_slide():
	if jumping and velocity.y > 0:
		jumping = false
	var snap = Vector2(0, 8)
	if jumping:
		snap = Vector2()
	
	velocity = move_and_slide_with_snap(velocity, snap, Vector2(0,-1), true, 4, deg2rad(46), true)
	
func apply_movement_in_ladder():
	if walk_right:
			#movimento basico direita
			velocity.x = speed / 2
			sprite.flip_h = false
			$ColissionWall.rotation_degrees = 270
	elif walk_left:
		#movimento basico esquerda
		velocity.x = -speed / 2
		sprite.flip_h = true
		$ColissionWall.rotation_degrees = 90
	elif walk_up:
		#movimento basico esquerda
		velocity.y = -speed / 3
	elif walk_down:
		#movimento basico esquerda
		velocity.y = speed / 3
	else:
		velocity.x = 0
		velocity.y = 0
	
	apply_move_and_slide()
	
func apply_movement():
	velocity.x = 0
	
	if walk_right:
		#movimento basico direita
		velocity.x += speed
		sprite.flip_h = false
		
	if walk_left:
		#movimento basico esquerda
		velocity.x -= speed
		sprite.flip_h = true
	
	apply_move_and_slide()
	
func apply_jump():
	if is_on_floor():
		if jump:
			jumping = true
			velocity.y = jump_force
		elif jump_stop:
			if velocity.y < 0:
				velocity.y *= 0.5

func apply_double_jump():
	#pulo duplo
	velocity.y = jump_force
	$DoubleJumpParticle.emitting = true
	$DoubleJumpParticle2.emitting = true
	$DoubleJumpParticle.emitting = false
	$DoubleJumpParticle2.emitting = false

func apply_dash():
	#dash
	if $Sprite.flip_h:
		walk_left = true
	else:
		walk_right = true
	speed *= dash_multiplier
		#permite que o dash no ar faça o player cair apenas no final (muito usado em metroidvanias pelo que eu vi)
	velocity.y = 0
	$Times/DashTime.start()
	$Times/DashDelay.start()
		
#emite o sinal que altera o valor da vida no HUD
func life_changed():
	emit_signal('life_changed', current_life * (100/max_life))

#função que recebe o dano e reduz a vida do player
func take_damage(damage):
	if not delay_after_damage:
		current_life -= damage
		life_changed()
		delay_after_damage = true
		$Times/DelayAfterDamageTime.start()
		anim.play("take_damage")
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
	speed /= dash_multiplier

func _on_AtkTime_timeout():
	atk_delay = false

func _on_ladderArea_body_entered(body):
	in_ladder = true

func _on_ladderArea_body_exited(body):
	in_ladder = false

func _on_DashDelay_timeout():
	dash_delay = false

func _on_AirAtkTime_timeout():
	atk_delay = false
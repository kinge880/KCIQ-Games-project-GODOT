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
var double_jump = false
var in_ladder = false
export var gravity = 800
var velocity = Vector2()
onready var sprite = $Sprite
onready var anim = $AnimationPlayer
onready var walk_concrete = $Sounds/PlayerWalkConcrete
var walk_right
var walk_left
var walk_up 
var walk_down
var released_right
var released_left
var jump
var jump_stop
var lower_move
var dash
var atk
var jumping = false

func _ready(): 
	emit_signal('life_changed', current_life * (100/max_life))

#aplica gravidade padrão
func apply_gravity(delta):
	velocity.y += gravity * delta 

#aplica gravidade ao agarrar uma parede
func apply_gravity_in_wall(delta):
	velocity.y = gravity * delta

#aplica o movimento
func apply_move_and_slide():
	if jumping and velocity.y > 0:
		jumping = false
	var snap = Vector2(0, 8)
	if jumping:
		snap = Vector2()
	
	velocity = move_and_slide_with_snap(velocity, snap, Vector2(0,-1), true, 4, deg2rad(46), true)

#movimento sem gravidade para todas as 4 direções, pode ser usado em escadas e outras coisas
func apply_movement_in_ladder():
	if walk_right:
		velocity.x = speed / 2
		sprite.flip_h = false
	elif walk_left:
		velocity.x = -speed / 2
		sprite.flip_h = true
	elif walk_up:
		velocity.y = -speed / 3
	elif walk_down:
		velocity.y = speed / 3
	else:
		velocity.x = 0
		velocity.y = 0
	
	apply_move_and_slide()

#movimento basico para a direita e esquerda
func apply_movement():
	velocity.x = 0
	if walk_right:
		velocity.x += speed
		sprite.flip_h = false
	if walk_left:
		velocity.x -= speed
		sprite.flip_h = true
	
	apply_move_and_slide()

#pulo
func apply_jump():
	if is_on_floor():
		if jump:
			jumping = true
			velocity.y = jump_force
	elif jump_stop:
		print("eita teste")
		if velocity.y < 0:
			velocity.y *= 0.5

#pulo duplo
func apply_double_jump():
	velocity.y = jump_force

#salto para o salto na parede em ambas as direções
func apply_jump_wall():
	if sprite.flip_h:
		velocity.x = speed * 1.5
		velocity.y = jump_force
	if not sprite.flip_h:
		velocity.x = -speed * 1.5
		velocity.y = jump_force

#dash
func apply_dash():
	if $Sprite.flip_h:
		walk_left = true
	else:
		walk_right = true
	speed *= dash_multiplier
	velocity.y = 0
	$Times/DashTime.start()
	$Times/DashDelay.start()

func apply_atk():
	$Times/AtkTime.start()
	atk_delay = true
			
func apply_air_atk():
	$Times/AirAtkTime.start()
	atk_delay = true
	
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

#entra em escada
func _on_ladderArea_body_entered(body):
	in_ladder = true

#sai de escada
func _on_ladderArea_body_exited(body):
	in_ladder = false

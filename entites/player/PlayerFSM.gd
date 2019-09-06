extends KinematicBody2D

onready var animation = $AnimationPlayer
onready var dash_delay = $Timers/DashDelay
onready var dash_timer = $Timers/DashTimer
onready var energy_reload_timer = $Timers/EnergyReload
onready var gliding_cost_timer = $Timers/GlidingEnergyConsumed
onready var sprite = $Sprite

export var dash_obted = true
export var double_jump_obted = true
export var jetpack_obted = true
export var gel_gun_obted = true
export var time_gun_obted = true
export var max_life = 100
export var current_life = 100
export var max_energy = 100
export var current_energy = 100

signal gel_shoot
signal life_changed
signal energy_changed
signal power_crystal_changed

enum State {
	CROUCHING,
	STANDING,
	DASHING,
	JUMPING,
	GLIDING,
	RELOAD
}

const WALK_SPEED = 200
const JUMP_SPEED = -250
const GRAVITY = 800
const SNAP = Vector2(0, 8)
const GEL_BULLET = preload("res://assets/bullets/GelBullet.tscn")

var velocity = Vector2.ZERO
var state = State.STANDING
var delay_after_damage = true
var power_crystal = 90

func _ready(): 
	emit_signal('life_changed', current_life * (100/max_life))
	emit_signal('power_crystal_changed', power_crystal)
	
# função para capturar a direção do Player
func update_velocity():
	
	velocity.x = 0
	
	if Input.is_action_pressed("ui_right"):
		velocity.x += WALK_SPEED
		sprite.flip_h = false
	elif Input.is_action_pressed("ui_left"):
		velocity.x -= WALK_SPEED
		sprite.flip_h = true


# estado em pé
func standing():
	
	update_velocity()
	
	# verifica se o Player está parado
	if velocity.x == 0:
		animation.play("idle")
	else:
		animation.play("walk")
	
	if Input.is_action_pressed("ui_down"):
		state = State.CROUCHING
	
	jump_transition()
	dash_transition()
	gel_shoot()
	
	velocity = move_and_slide_with_snap(velocity, SNAP, Vector2.UP, true, 4, deg2rad(46), true)


# estado pulando
func jumping(delta):
	
	update_velocity()
	
	# verifica se o Player está subindo ou descendo
	if velocity.y < 0:
		animation.play("jump")
	else:
		animation.play("fall")
	
	# limita a altura do pulo
	if Input.is_action_just_released("ui_up"):
		velocity.y = max(velocity.y, -50.0)
	
	velocity.y += GRAVITY * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	
	dash_transition()
	gliding_transition()
	
	if is_on_floor():
		state = State.STANDING


# função para auxiliar a transição para o estado pulando
func jump_transition():
	
	if not is_on_floor():
		state = State.JUMPING
	elif Input.is_action_just_pressed("ui_up"):
		velocity.y = JUMP_SPEED
		state = State.JUMPING


# estado planando
func gliding(delta):
	
	update_velocity()
	
	if gliding_cost_timer.time_left == 0:
		current_energy -= 1
		energy_changed()
		gliding_cost_timer.start()
		
	if current_energy > 1:
		animation.play("ladder")
		# muda a gravidade durante a planagem
		velocity.y = GRAVITY * 2 * delta
		velocity = move_and_slide(velocity, Vector2.UP)
	else:
		state = State.JUMPING
		
	gliding_transition()
	
	if is_on_floor():
		state = State.STANDING


# função para auxiliar a transição para o estado planando
func gliding_transition():
	
	if jetpack_obted and not is_on_floor():
		if Input.is_action_just_pressed("gliding"):
			state = State.GLIDING
		elif Input.is_action_just_released("gliding"):
			state = State.JUMPING


# estado "arrojado" (Google Translate)
func dashing():
	
	animation.play("dash")
	
	var dash_velocity = Vector2(velocity.x * 2, 1)
	dash_velocity = move_and_slide(dash_velocity, Vector2.UP)
	if dash_timer.time_left == 0:
		dash_timer.start()


# função para auxiliar a transição para o estado "arrojado"
func dash_transition():

	# verifica se o delay do dash já acabou e se o player está se movendo 
	if dash_obted and dash_delay.time_left == 0 && velocity.x != 0:
		if Input.is_action_just_pressed("ui_select"):
			state = State.DASHING


# estado agachado
func crouching():
	
	animation.play("crouch")
	
	jump_transition()
	
	if Input.is_action_just_released("ui_down"):
		state = State.STANDING


#ativa um tiro da arma de gel
func gel_shoot():
	
	if current_energy >= 5:
		if Input.is_action_just_released("ui_weak_attack"):
			#pega posição atual do mouse e emite o sinal de tiro para o mapa
			var mspos = get_global_mouse_position()
			emit_signal('gel_shoot', GEL_BULLET, global_position, mspos - global_position)
			current_energy -= 5
			energy_changed()
	else:
		pass
		#aplicar um som de não balas e pá
	
	if Input.is_action_pressed("reload") and current_energy < 100:
		state = State.RELOAD


# estado de recarga da energia
func reload():
	
	if energy_reload_timer.time_left == 0 and power_crystal > 0:
		animation.play("crouch")
		current_energy += 1
		power_crystal -= 1
		energy_changed()
		power_crystal_changed()
		energy_reload_timer.start()
	if current_energy == 100:
		state = State.STANDING
	elif power_crystal <= 0:
		state = State.STANDING
	elif Input.is_action_just_released("reload"):
		state = State.STANDING


#emite o sinal que altera o numero de cristais de energia HUD
func power_crystal_changed():
	
	emit_signal('power_crystal_changed', power_crystal)
	
	
#emite o sinal que altera o valor da energia no HUD
func energy_changed():
	
	emit_signal('energy_changed', current_energy * (100/max_energy))
	
	
#emite o sinal que altera o valor da vida no HUD
func life_changed():
	
	emit_signal('life_changed', current_life * (100/max_life))

#função que recebe o dano e reduz a vida do player
func take_damage(damage):
	
	if not delay_after_damage:
		current_life -= damage
		life_changed()
		delay_after_damage = true
		$Timers/DelayAfterDamageTime.start()
		animation.play("take_damage")
	if current_life <=0:
		#fazer funções de morte depois
		death()


#função que ativa a condição de morte, fazer depois
func death():
	
	queue_free()
	
	
func _physics_process(delta):
	
	match state:
		State.STANDING:
			standing()
		State.JUMPING:
			jumping(delta)
		State.DASHING:
			dashing()
		State.CROUCHING:
			crouching()
		State.GLIDING:
			gliding(delta)
		State.RELOAD:
			reload()


# finaliza o dash
func _on_DashTimer_timeout():
	
	dash_delay.start()
	
	# reseta o movimento do Player após o dash
	velocity = Vector2.ZERO
	
	if not is_on_floor():
		state = State.JUMPING
	else:
		state = State.STANDING
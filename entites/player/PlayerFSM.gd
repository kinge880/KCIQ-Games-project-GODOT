extends KinematicBody2D

onready var animation = $AnimationPlayer
onready var dash_delay = $Timers/DashDelay
onready var dash_timer = $Timers/DashTimer
onready var energy_reload_timer = $Timers/EnergyReload
onready var energy_reload_timer_delay = $Timers/EnergyReloadDelay
onready var gliding_cost_timer = $Timers/GlidingEnergyConsumed
onready var big_jump_delay = $Timers/BigJumpDelay
onready var sprite = $Sprite

#coloquei variaveis de todo tipo de custo/energia e pá, como exportadas, para facilitar os testes, já que basta alterar no inspetor
#as variaveis de custo são necessarias no futuro quando implementarmos os mods para o nucleo de energia
export var dash_obted = true
export var double_jump_obted = true
export var jetpack_obted = true
export var gel_gun_obted = true
export var time_gun_obted = true
export var max_life = 100
export var current_life = 100
export var max_energy = 100
export var current_energy = 100
export var big_jump_cost = 1
export var gliding_cost = 1
export var gel_gun_cost = 5
export var reload_power_cristal_cost = 1
export var reload_energy_restored = 1

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
	RELOAD,
	BIG_JUMP,
	DOUBLE_JUMP
}

const WALK_SPEED = 200
const JUMP_SPEED = -250
const GRAVITY = 800
const SNAP = Vector2(0, 8)
const GEL_BULLET = preload("res://assets/bullets/GelBullet.tscn")

var velocity = Vector2.ZERO
var state = State.STANDING
var delay_after_damage = true
var power_crystal = 100
var camera_zoom = false

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
	
	# verifica se o Player está parado
	if velocity.x == 0:
		animation.play("idle")
	else:
		animation.play("walk")
	
	if Input.is_action_pressed("ui_down"):
		crouching_transition()
	
	update_velocity()
	jump_transition()
	dash_transition()
	gel_shoot()
	
	if camera_zoom:
		camera_zoom = false
		$AnimationPlayer2.play("camera_zoom_in")
	velocity = move_and_slide_with_snap(velocity, SNAP, Vector2.UP, true, 4, deg2rad(46), true)
	
	if Input.is_action_pressed("reload") and current_energy < max_energy and power_crystal > 0:
		energy_reload_timer_delay.start()
		state = State.RELOAD

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
	
	#ativa o estado de pulo duplo
	if Input.is_action_just_pressed("ui_up") and double_jump_obted:
		velocity.y = JUMP_SPEED
		state = State.DOUBLE_JUMP
	
	if is_on_floor():
		state = State.STANDING


# função para auxiliar a transição para o estado pulando
func jump_transition():
	
	if not is_on_floor():
		state = State.JUMPING
	elif Input.is_action_just_pressed("ui_up"):
		velocity.y = JUMP_SPEED
		state = State.JUMPING


# estado de pulo duplo
func double_jump(delta):
	
	update_velocity()
	
	# verifica se o Player está subindo ou descendo
	if velocity.y < 0:
		animation.play("double_jump")
	else:
		animation.play("fall")
	
	velocity.y += GRAVITY * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	
	dash_transition()
	gliding_transition()
	
	if is_on_floor():
		state = State.STANDING


# estado planando
func gliding(delta):
	
	update_velocity()
	
	if gliding_cost_timer.time_left == 0:
		current_energy -= gliding_cost
		energy_changed()
		gliding_cost_timer.start()
		
	if current_energy > gliding_cost:
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
	
	if big_jump_delay.time_left == 0 and current_energy > big_jump_cost:
		if Input.is_action_pressed("ui_up"):
			camera_zoom = true
			$AnimationPlayer2.play("camera_zoom_out")
		big_jump_transition()
		emit_signal('energy_changed', current_energy * (100/max_energy))
		$DoubleJumpParticle.emitting = true
		$DoubleJumpParticle2.emitting = true
	else:
		jump_transition()
	if Input.is_action_just_released("ui_down"):
		state = State.STANDING
		$DoubleJumpParticle.emitting = false
		$DoubleJumpParticle2.emitting = false


# auxilio para chegar corretamente no estado agachado
func crouching_transition():
	
	# ativa o timer para carregar o super pulo
	big_jump_delay.start()
	state = State.CROUCHING


#ativa um tiro da arma de gel
func gel_shoot():
	
	if current_energy >= gel_gun_cost:
		if Input.is_action_just_released("ui_weak_attack"):
			#pega posição atual do mouse e emite o sinal de tiro para o mapa
			var mspos = get_global_mouse_position()
			emit_signal('gel_shoot', GEL_BULLET, global_position, mspos - global_position)
			current_energy -= gel_gun_cost
			energy_changed()
	else:
		pass
		#aplicar um som de não balas e pá


# estado de recarga da energia
func reload():
	animation.play("crouch")
	
	if Input.is_action_just_released("reload") or current_energy == max_energy or power_crystal <= 0:
		state = State.STANDING
	elif energy_reload_timer_delay.time_left == 0:
		if energy_reload_timer.time_left == 0:
			current_energy += reload_energy_restored
			power_crystal -= reload_power_cristal_cost
			energy_changed()
			power_crystal_changed()
			energy_reload_timer.start()


#estado do super pulo
func big_jump(delta):
	
	update_velocity()
	big_jump_transition()
	
	if velocity.y < 0:
		animation.play("jump")
	else:
		$DoubleJumpParticle.emitting = false
		$DoubleJumpParticle2.emitting = false
		state = State.JUMPING
	
	velocity.y += GRAVITY * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	
	if is_on_floor():
		state = State.STANDING


# função para auxiliar a transição para o estado pulando
func big_jump_transition():
	
	if Input.is_action_pressed("ui_up") and current_energy > big_jump_cost:
		if gliding_cost_timer.time_left == 0:
			current_energy -= big_jump_cost
			emit_signal('energy_changed', current_energy * (100/max_energy))
		velocity.y = JUMP_SPEED
		state = State.BIG_JUMP
	elif Input.is_action_just_released("ui_up"):
		$DoubleJumpParticle.emitting = false
		$DoubleJumpParticle2.emitting = false
		state = State.JUMPING
		
		
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
		State.BIG_JUMP:
			big_jump(delta)
		State.DOUBLE_JUMP:
			double_jump(delta)


# finaliza o dash
func _on_DashTimer_timeout():
	
	dash_delay.start()
	
	# reseta o movimento do Player após o dash
	velocity = Vector2.ZERO
	
	if not is_on_floor():
		state = State.JUMPING
	else:
		state = State.STANDING
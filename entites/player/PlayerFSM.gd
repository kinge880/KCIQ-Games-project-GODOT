extends KinematicBody2D

onready var animation = $AnimationPlayer
onready var animation_effects = $AnimationEffects
onready var dash_delay = $Timers/DashDelay
onready var energy_reload_timer = $Timers/EnergyReload
onready var energy_reload_timer_delay = $Timers/EnergyReloadDelay
onready var gliding_cost_timer = $Timers/GlidingEnergyConsumed
onready var big_jump_delay = $Timers/BigJumpDelay
onready var fast_time_cost = $Timers/FastTimeCost
onready var attack_delay = $Timers/AttackTimer
onready var air_attack_delay = $Timers/AerialAttackTimer
onready var sprite = $Sprite
onready var check_wall_botton = $CheckWallBotton
#onready var check_wall_left = $RayCasts/CheckWallLeft
onready var check_wall_top = $CheckWallTop
#onready var check_wall_top_left = $RayCasts/CheckWallTopLeft
onready var sound_not_energy = $Sounds/NotEnergy
onready var sound_fast_time_duration = $Sounds/FastTime/FastTimeDuration
onready var sound_fast_time_active = $Sounds/FastTime/FastTimeActive
onready var sound_fast_time_desactive = $Sounds/FastTime/FastTimeDesactive
onready var sound_time_travel_active = $Sounds/TimeTravel/TimeTravelActive
onready var time_travel_duration = $Timers/TimeTravelDuration
onready var time_travel_duration_play = $Timers/TimeTravelDurationSoundPlay
onready var sound_time_travel_reactive = $Sounds/TimeTravel/TimeTravelReactive
onready var sound_time_travel_duration = $Sounds/TimeTravel/TimeTravelDuration
onready var double_jump_delay = $Timers/DoubleJumpDelay

#coloquei variaveis de todo tipo de custo/energia e pá, como exportadas, para facilitar os testes, já que basta alterar no inspetor
#as variaveis de custo são necessarias no futuro quando implementarmos os mods para o nucleo de energia
export var max_life = 100
export var current_life = 100
export var max_energy = 100
export var current_energy = 100
export var big_jump_cost = 1
export var gliding_cost = 1
export var gel_gun_cost = 5
export var time_gun_cost = 20
export var reload_power_cristal_cost = 1
export var reload_energy_restored = 1
export var sword_damage = 5

signal gel_shoot
signal time_shoot
signal life_changed
signal energy_changed
signal power_crystal_changed
signal hability_changed

enum State {
	CROUCHING,
	STANDING,
	DASHING,
	JUMPING,
	GLIDING,
	RELOAD,
	BIG_JUMP,
	DOUBLE_JUMP,
	ATTACK,
	AIR_ATTACK,
	DAMAGED,
	GRAB_WALL
}
enum State_hability {
	TIME_SHOOT,
	GEL_SHOOT,
	FAST_TIME,
	TIME_TRAVEL,
	#BLINK
}

const SNAP = Vector2(0, 8)
const GEL_BULLET = preload("res://assets/package/bullets/gel_bullet/GelBullet.tscn")
const TIME_BULLET = preload("res://assets/package/bullets/time_bullet/time_bullet.tscn")

var JUMP_SPEED = -250
var GRAVITY = 800
var WALK_SPEED = 200
var velocity = Vector2.ZERO
var state = State.STANDING
var state_hability = State_hability.TIME_SHOOT
var power_crystal = 100
var enemy_damage_position
var enemy_damage_force
var in_jump = false
var delay_after_damage = false
var hability = 1
var hability_name = "Time Shoot"
var player_global_position
var hability_active = false
var double_jump_active = true

func _ready(): 
	life_changed()
	energy_changed()
	power_crystal_changed()
	add_to_group("player")
	emit_signal('hability_changed', hability_name)
	
# função para capturar a direção do Player
func update_velocity():
	
	velocity.x = 0
	
	if Input.is_action_pressed("ui_right"):
		if sprite.flip_h:
			$SwordSlice.position.x *= -1
			$Body.position.x *= -1
			check_wall_botton.cast_to.x = 10
			check_wall_top.cast_to.x = 10
		sprite.flip_h = false
		velocity.x += WALK_SPEED
	elif Input.is_action_pressed("ui_left"):
		if not sprite.flip_h:
			$SwordSlice.position.x *= -1
			$Body.position.x *= -1
			check_wall_botton.cast_to.x = -10
			check_wall_top.cast_to.x = -10
		sprite.flip_h = true
		velocity.x -= WALK_SPEED


# estado em pé
func standing(delta):
	
	# verifica se o Player está parado
	if velocity.x == 0:
		animation.play("idle")
	else:
		animation.play("walk")
	
	if Input.is_action_pressed("ui_down"):
		crouching_transition()
	if is_on_floor():
		double_jump_active = true
		
	update_velocity()
	velocity.y += GRAVITY * delta
	velocity = move_and_slide_with_snap(velocity, SNAP, Vector2.UP, true, 4, deg2rad(46), true)
	jump_transition()
	dash_transition()
	attack_transition()

	if Input.is_action_pressed("reload_energy") and current_energy < max_energy and power_crystal > 0:
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
	grab_wall_transition()
	dash_transition()
	double_jump_transition()
	air_attack_transition()
	
	if current_energy > gliding_cost:
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


# estado de pulo duplo
func double_jump(delta):
	
	update_velocity()
	
	animation.play("double_jump")
	velocity.y += GRAVITY * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	
	grab_wall_transition()
	dash_transition()
	
	if current_energy > gliding_cost:
		gliding_transition()
	if is_on_floor():
		state = State.STANDING
	elif Input.is_action_pressed("ataque_arma_primaria"):
		state = State.AIR_ATTACK


#ativa o estado de pulo duplo
func double_jump_transition():
	
	if  double_jump_active and PlayerGlobalsVariables.double_jump_obtained and Input.is_action_just_pressed("ui_up"):
		double_jump_active = false
		velocity.y = JUMP_SPEED
		state = State.DOUBLE_JUMP


#estado do super pulo
func big_jump(delta):
	
	update_velocity()
	big_jump_transition()
	
	if velocity.y < 0:
		animation.play("jump")
	else:
		$JetPackParticle.emitting = false
		$JetPackParticle2.emitting = false
		state = State.JUMPING
	
	velocity.y += GRAVITY * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	
	if is_on_floor():
		state = State.STANDING


# função para auxiliar a transição para o estado pulando
func big_jump_transition():
	
	if PlayerGlobalsVariables.big_jump_obtained and Input.is_action_pressed("ui_up") and current_energy > big_jump_cost:
		if gliding_cost_timer.time_left == 0:
			current_energy -= big_jump_cost
			energy_changed()
		velocity.y = JUMP_SPEED
		state = State.BIG_JUMP
	elif Input.is_action_just_released("ui_up"):
		$JetPackParticle.emitting = false
		$JetPackParticle2.emitting = false
		state = State.JUMPING


#pulo DELICIOSO na parede
func grab_wall(delta):
	
	#saltos para a direita e esquerda da parede, bixo isso ficou muito verboso kkk, maas não tem jeito, preciso fazer esses ajustes em cada pulo
	if Input.is_action_pressed("ui_right") and not Input.is_action_just_pressed("ui_left") and Input.is_action_just_pressed("ui_up") and not in_jump and sprite.flip_h == true:
		velocity.x += WALK_SPEED
		velocity.y = JUMP_SPEED
		in_jump = true
		sprite.flip_h = false
		check_wall_botton.cast_to.x = 10
		check_wall_top.cast_to.x = 10
		$SwordSlice.position.x *= -1
		$Body.position.x *= -1
		$Timers/WallJumpDelay.start()
	if Input.is_action_pressed("ui_left") and not Input.is_action_pressed("ui_right") and Input.is_action_just_pressed("ui_up") and not in_jump and sprite.flip_h == false:
		velocity.x -= WALK_SPEED
		velocity.y = JUMP_SPEED
		in_jump = true
		sprite.flip_h = true
		check_wall_botton.cast_to.x = -10
		check_wall_top.cast_to.x = -10
		$SwordSlice.position.x *= -1
		$Body.position.x *= -1
		$Timers/WallJumpDelay.start()
	
	#essa in_jump define se eu saltei ou não, é preciso usar ela para uma transição controlada entre os estados
	#permitindo alterna entre as gravidades no momento correto e executar o salto em si
	if in_jump:
		if $Timers/WallJumpDelay.time_left == 0:
			in_jump = false
			state = State.JUMPING
		animation.play("jump")
		#update_velocity()
		velocity.y += GRAVITY * delta
	else:
		if check_wall_botton.is_colliding() and check_wall_top.is_colliding():
			animation.play("grab_wall")
			velocity.y = GRAVITY * delta
			
			if is_on_floor() or Input.is_action_just_pressed("ui_down"):
				if sprite.flip_h == false:
					sprite.flip_h = true
					$SwordSlice.position.x *= -1
					$Body.position.x *= -1
					check_wall_botton.cast_to.x = -10
					check_wall_top.cast_to.x = -10
				if sprite.flip_h == true:
					sprite.flip_h = false
					$SwordSlice.position.x *= -1
					$Body.position.x *= -1
					check_wall_botton.cast_to.x = 10
					check_wall_top.cast_to.x = 10
				state = State.JUMPING
		#isso aqui permite que o player de uma leve subidinha ao tocar na ponta de uma borda (será bom uma animação dele agarando na borda e subindo)
		elif not check_wall_top.is_colliding() and check_wall_botton.is_colliding():
			velocity.y = JUMP_SPEED / 2
			animation.play("ladder")
		else:
			state = State.JUMPING
		
	velocity = move_and_slide(velocity, Vector2.UP)


# função para auxiliar a transição para o estado agarrado na parede
func grab_wall_transition():
	
	if PlayerGlobalsVariables.wall_jump_obtained and not is_on_floor() and is_on_wall():
		state = State.GRAB_WALL


# estado planando
func gliding(delta):
	
	update_velocity()
	grab_wall_transition()
	"""if gliding_cost_timer.time_left == 0:
		current_energy -= gliding_cost
		energy_changed()
		gliding_cost_timer.start()
		
	if current_energy > gliding_cost:"""
	animation.play("ladder")
	# muda a gravidade durante a planagem
	velocity.y = GRAVITY * 2 * delta
	velocity.x = velocity.x / 2
	velocity = move_and_slide(velocity, Vector2.UP)
	"""else:
		state = State.JUMPING"""
		
	gliding_transition()
	
	if is_on_floor():
		state = State.STANDING


# função para auxiliar a transição para o estado planando
func gliding_transition():
	
	if PlayerGlobalsVariables.jetpack_obtained and not is_on_floor():
		if Input.is_action_just_pressed("gliding"):
			state = State.GLIDING
		elif Input.is_action_just_released("gliding"):
			state = State.JUMPING


# estado "arrojado" (Google Translate)
func dashing():
	
	var dash_velocity = Vector2(WALK_SPEED * 2, 1)
	
	if sprite.flip_h == true:
		dash_velocity = move_and_slide(-dash_velocity, Vector2.UP)
	else:
		dash_velocity = move_and_slide(dash_velocity, Vector2.UP)


# função para auxiliar a transição para o estado "arrojado"
func dash_transition():
	
	#verifica se o delay do dash já acabou e se o player está se movendo, além de verificar se ele esta no ar ou em terra
	if not is_on_floor() and PlayerGlobalsVariables.dash_obtained and dash_delay.time_left == 0:
		if Input.is_action_just_pressed("ui_select"):
			state = State.DASHING
			animation.play("air_dash")
	elif dash_delay.time_left == 0:
		if Input.is_action_just_pressed("ui_select"):
			state = State.DASHING
			animation.play("dash")
			delay_after_damage = true


# estado agachado
func crouching():
	
	animation.play("crouch")
	
	if big_jump_delay.time_left == 0 and current_energy > big_jump_cost:
		big_jump_transition()
		energy_changed()
		$JetPackParticle.emitting = true
		$JetPackParticle2.emitting = true
	else:
		jump_transition()
	if Input.is_action_just_released("ui_down"):
		state = State.STANDING
		$JetPackParticle.emitting = false
		$JetPackParticle2.emitting = false


# auxilio para chegar corretamente no estado agachado
func crouching_transition():
	
	# ativa o timer para carregar o super pulo
	big_jump_delay.start()
	state = State.CROUCHING


func get_hability():
	pass


func change_hability():
	
	if Input.is_action_just_pressed("change_secondary_weapon_up"):
		hability += 1
		
		if hability > State_hability.size():
			hability = 1
	
	elif Input.is_action_just_pressed("change_secondary_weapon_down"):
		hability -= 1
		
		if hability < 1:
			hability = State_hability.size()
	
	if Input.is_action_just_pressed("change_secondary_weapon_down") or Input.is_action_just_pressed("change_secondary_weapon_up"):
		
		if hability_active and hability_name == "Fast Time":
			get_tree().call_group("enemies","stop_player_fast_time")
			hability_active = false
			modulate = Color.white
			WALK_SPEED /= 1.5
			JUMP_SPEED /= 1.5
			GRAVITY /= 1.5
			animation.playback_speed /= 1.5
			animation.playback_speed /= 1.5
			sound_fast_time_duration.stop()
			$Sounds/FastTime/FastTimeDesactiveChanged.play()
		else:
			$Sounds/misc/ChangeHability.play()
			
		hability_active = false
		modulate = Color.white
		
		match hability:
			1:
				state_hability = State_hability.TIME_SHOOT
				hability_name = "Time Shoot"
			2:
				state_hability = State_hability.GEL_SHOOT
				hability_name = "Gel Shoot"
			3:
				state_hability = State_hability.FAST_TIME
				hability_name = "Fast Time"
			4:
				state_hability = State_hability.TIME_TRAVEL
				hability_name = "Time Travel"
			#5:
				#state_hability = State_hability.BLINK
				#hability_name = "BLINK"
			
		emit_signal('hability_changed', hability_name)
		
	match state_hability:
		
		State_hability.TIME_SHOOT:
			time_shoot()
		State_hability.GEL_SHOOT:
			gel_shoot()
		State_hability.FAST_TIME:
			fast_time()
		State_hability.TIME_TRAVEL:
			time_travel()
		#State_hability.BLINK:
			#blink_transition()

#função que ativa a habilidade fast_time, tornando os inimigos lentos e o player mais rapido (velocidade e animações)
func fast_time():
	
	if not hability_active and current_energy >= PlayerGlobalsVariables.fast_time_cost * 10:
		if Input.is_action_just_pressed("ataque_arma_secundaria"):
			get_tree().call_group("enemies","start_player_fast_time")
			hability_active = true
			modulate = Color.red
			WALK_SPEED *= 1.5
			JUMP_SPEED *= 1.5
			GRAVITY *= 1.5
			animation.playback_speed *= 1.5
			animation.playback_speed *= 1.5
			current_energy -= PlayerGlobalsVariables.fast_time_cost * 10
			energy_changed()
			fast_time_cost.start()
			sound_fast_time_active.play()
	elif hability_active:
		if Input.is_action_just_pressed("ataque_arma_secundaria") or current_energy <= PlayerGlobalsVariables.fast_time_cost:
			desactive_fast_time()
		elif fast_time_cost.time_left == 0:
			current_energy -= PlayerGlobalsVariables.fast_time_cost
			energy_changed()
			fast_time_cost.start()
	else:
		if Input.is_action_just_pressed("ataque_arma_secundaria"):
			sound_not_energy.play()
		
	#modula o pith do som de duração com base na energia restante
	if current_energy * (100/max_energy) < 20:
		sound_fast_time_duration.pitch_scale = 1 + (0.03 * (50 - current_energy))
	elif current_energy * (100/max_energy) < 50:
		sound_fast_time_duration.pitch_scale = 1 + (0.02 * (50 - current_energy))
	else:
		sound_fast_time_duration.pitch_scale = 1


func desactive_fast_time():
	
	get_tree().call_group("enemies","stop_player_fast_time")
	hability_active = false
	modulate = Color.white
	WALK_SPEED /= 1.5
	JUMP_SPEED /= 1.5
	GRAVITY /= 1.5
	animation.playback_speed /= 1.5
	animation.playback_speed /= 1.5
	sound_fast_time_duration.stop()
	sound_fast_time_desactive.pitch_scale = sound_fast_time_duration.pitch_scale
	sound_fast_time_desactive.play()


#estado de viagem no tempo, retorna o tempo apenas para o player após alguns segundos ou após a reativação
func time_travel():
	
	#se a variavel chave for falsa e tiver energia o bastante salva a posição do player e ativa som/animações
	if not hability_active and current_energy >= PlayerGlobalsVariables.time_travel_cost:
		if Input.is_action_just_pressed("ataque_arma_secundaria"):
			player_global_position = global_position
			hability_active = true
			modulate = Color.blue
			sound_time_travel_active.play()
			time_travel_duration.start()
			time_travel_duration_play.start()
	#reativa a habilidade retornando ao ponto marcado e ativa custo de energia
	elif hability_active:
		if Input.is_action_just_pressed("ataque_arma_secundaria") or time_travel_duration.time_left == 0:
			global_position = player_global_position
			hability_active = false
			modulate = Color.white
			current_energy -= PlayerGlobalsVariables.time_travel_cost
			energy_changed()
			sound_time_travel_reactive.play()
		
		#usado para aumentar a velocidade dos beeps alertando sobre o fim da duração dessa habilidade
		time_travel_duration_play.wait_time = time_travel_duration.time_left / 5
	
		if time_travel_duration_play.time_left == 0:
			sound_time_travel_duration.play()
			time_travel_duration_play.start()
	else:
		if Input.is_action_just_pressed("ataque_arma_secundaria"):
			sound_not_energy.play()


"""func blink_transition():
	
	var teleport_distance = 100
	var direction = Vector2()
	var speed = WALK_SPEED
	
	if Input.is_action_just_pressed("ataque_arma_secundaria"):
		print("chegou")
		if len($TeleportArea.get_overlapping_bodies()) == 0:
			position = $TeleportArea.global_position
			#state = State.BLINK
		else:
			position = $TeleportColision.get_collision_point()
			#state = State.BLINK
	# This section listens for User Input.
	if Input.is_action_pressed("ui_up"):
		direction.y = -1
	if Input.is_action_pressed("ui_left"):
		direction.x = -1
	if Input.is_action_pressed("ui_down"):
		direction.y = 1
	if Input.is_action_pressed("ui_right"):
		direction.x = 1
	
	direction = direction.normalized()
	$TeleportArea.position = teleport_distance * direction
	$TeleportColision.rotate(direction.angle())
 

func blink():
	#var movement = direction * speed * 7
#	movement = move_and_slide(movement)
	state = State.STANDING"""


#ativa um tiro da arma de gel
func gel_shoot():
	
	if current_energy >= gel_gun_cost and PlayerGlobalsVariables.gel_gun_obtained:
		if Input.is_action_just_pressed("ataque_arma_secundaria"):
			#pega posição atual do mouse e emite o sinal de tiro para o mapa
			var mspos = get_global_mouse_position()
			emit_signal('gel_shoot', GEL_BULLET, global_position, mspos - global_position)
			current_energy -= gel_gun_cost
			energy_changed()
	else:
		if Input.is_action_just_pressed("ataque_arma_secundaria"):
			sound_not_energy.play()


#ativa um tiro da arma do tempo
func time_shoot():
	
	if PlayerGlobalsVariables.time_gun_obtained and current_energy >= time_gun_cost:
		if Input.is_action_just_pressed("ataque_arma_secundaria"):
			#pega posição atual do mouse e emite o sinal de tiro para o mapa
			var mspos = get_global_mouse_position()
			emit_signal('time_shoot', TIME_BULLET, global_position, mspos - global_position)
			current_energy -= time_gun_cost
			energy_changed()
	else:
		if Input.is_action_just_pressed("ataque_arma_secundaria"):
			sound_not_energy.play()


# estado de recarga da energia
func reload():
	
	animation.play("crouch")
	
	if Input.is_action_just_released("reload_energy") or current_energy == max_energy or power_crystal <= 0:
		state = State.STANDING
	elif energy_reload_timer_delay.time_left == 0:
		if energy_reload_timer.time_left == 0:
			current_energy += reload_energy_restored
			power_crystal -= reload_power_cristal_cost
			energy_changed()
			power_crystal_changed()
			energy_reload_timer.start()


#ativa o estado de ataque no chão
func attack(delta):
	
	update_velocity()
	#coloar o que for neessario para efetuar o atk dd melhor forma possivel
	velocity.y += GRAVITY * delta
	velocity = move_and_slide_with_snap(velocity, SNAP, Vector2.UP, true, 4, deg2rad(46), true)


func attack_transition():
	
	if Input.is_action_just_pressed("ataque_arma_primaria") and attack_delay.time_left == 0:
		animation.play("atk2")
		attack_delay.start()
		state = State.ATTACK


#executa um ataque com a espada
func air_attack(delta):
	
	if is_on_floor():
		state = State.STANDING
	
	update_velocity()
	velocity.y += GRAVITY * delta
	velocity = move_and_slide_with_snap(velocity, SNAP, Vector2.UP, true, 4, deg2rad(46), true)


func air_attack_transition():
	
	if Input.is_action_just_pressed("ataque_arma_primaria") and attack_delay.time_left == 0:
		animation.play("air_atk")
		air_attack_delay.start()
		state = State.AIR_ATTACK


#emite o sinal que altera o numero de cristais de energia HUD
func power_crystal_changed():
	
	emit_signal('power_crystal_changed', power_crystal)


#emite o sinal que altera o valor da energia no HUD
func energy_changed():
	
	emit_signal('energy_changed', current_energy * (100/max_energy), current_energy)


#emite o sinal que altera o valor da vida no HUD
func life_changed():
	
	emit_signal('life_changed', current_life * (100/max_life), current_life)


#função auxiliar que recebe o dano, reduz a vida do player e muda para o estado damaged
func take_damage_transition(damage, direction_damage, damage_force):
	
	#pega a direção do enemy que causou o dano e a força do impacto, isso permite criar um 
	#tratamento para o player após ele receber o dano, como empurrar o player, ou algo do tipo
	enemy_damage_position = direction_damage
	enemy_damage_force = damage_force
	
	if not delay_after_damage:
		current_life -= damage
		life_changed()
		delay_after_damage = true
		animation_effects.play("take_damage")
		animation.play("damaged")
		state = State.DAMAGED


#estado damaged
func take_damage(delta):
	
	velocity.x = 0
	velocity.y = 0
	
	if enemy_damage_position.x > position.x:
		velocity.x -= enemy_damage_force
	elif enemy_damage_position.x < position.x:
		velocity.x += enemy_damage_force

	if current_life <= 0:
		#fazer funções de morte depois
		death()
	
	velocity.y += GRAVITY * delta
	velocity = move_and_slide_with_snap(velocity, SNAP, Vector2.UP, true, 4, deg2rad(46), true)


#função que ativa a condição de morte, fazer depois
func death():
	
	get_tree().reload_current_scene()


#função que coleta os cristais, nossa moeda e nossa fonte de energia
func collect_power_crystal(crystal_value):
	
	power_crystal += crystal_value
	power_crystal_changed()


func change_colisors():
	pass


func _physics_process(delta):
	
	change_hability()
	
	match state:
		State.STANDING:
			standing(delta)
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
		State.ATTACK:
			attack(delta)
		State.AIR_ATTACK:
			air_attack(delta)
		State.DAMAGED:
			take_damage(delta)
		State.GRAB_WALL:
			grab_wall(delta)


#ao terminar animações muda estados
func _on_AnimationPlayer_animation_finished(anim_name):
	#return

	if anim_name == "damaged" or anim_name == "double_jump" or anim_name == "atk2" or anim_name == "air_atk":
		state = State.STANDING
	# finaliza o dash
	if anim_name == "dash" or anim_name == "air_dash":
		if anim_name == "dash":
			delay_after_damage = false
		
		dash_delay.start()
		# reseta o movimento do Player após o dash
		velocity = Vector2.ZERO
	
		if not is_on_floor():
			state = State.JUMPING
		else:
			state = State.STANDING


#ao terminar animações muda estados
func _on_AnimationPlayer2_animation_finished(anim_name):
	
	if anim_name == "take_damage":
		delay_after_damage = false


#causa dano no ataque
func _on_SwordSlice_body_entered(body):
	
	if body.is_in_group("enemies"):
		#o body.animation.current_animation é necessario para impedir casos onde continue dropando moedas após a morte
		if body.has_method('take_damage') and body.animation.current_animation != "death":
			body.take_damage(sword_damage)


func _on_FastTimeActive_finished():
	
	if hability_active:
		sound_fast_time_duration.play()


func _on_FastTimeDesactiveChanged_finished():
	
	sound_fast_time_desactive.pitch_scale = sound_fast_time_duration.pitch_scale
	sound_fast_time_desactive.play()
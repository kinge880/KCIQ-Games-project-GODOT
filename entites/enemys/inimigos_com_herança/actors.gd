extends KinematicBody2D

onready var animation = $AnimationEnemy
onready var animation_effets = $AnimationEffects
onready var sprite = $Sprite
onready var hit_box = $HitBox/HitBoxColision
onready var hit_area = $HitBox
onready var dash_area = $DashZone
onready var vision_player = $VisionPlayer
onready var delay_after_damage = $Timers/DelayAfterDamage
onready var delay_jump = $Timers/DelayJump
onready var delay_fall = $Timers/DelayFall
onready var dash_delay = $Timers/DashDelay
onready var delay_shoot = $Timers/DelayShoot
onready var dash_duration = $Timers/DashDuration
onready var platform_drop = $FloorColision
onready var platform_wall = $WallColision
onready var coin_drop = preload("res://assets/package/collectible/PowerCristal.tscn")

export (int) var move_distance = 500 #distancia maxima que ele se move antes de virar
export (int) var max_life
export (int) var current_life
export (int) var damage #dano do enemy
export (int) var damage_force #força de empurrão que o player sofre ao ser atingido
export (float) var walk_speed #velocidade de movimento
export (int) var gravity #força da gravidade sobre o enemy
export (int) var jump_speed #velocidade do pulo
export (int) var drop_value #define o valor maximo dos cristais dropados
#numero de drops, esse valor define a chance cair 1 ou 5 drops
#o array[0] define a chance de cair 1 drop e o array[4] define a chance de cair 4
#quanto menor o valor, menor a chance de drop, pode se usar qualquer valor, mas é melhor se limitar a uma soma dos valores que de no maximo 200 por motivos de desempenho
export (Array) var drop_quantity = [
{quantity = 1, w = 50},
{quantity = 2, w = 40},
{quantity = 3, w = 20},
{quantity = 4, w = 10},
{quantity = 5, w = 5}]

var start_position = position
var end_position = start_position + Vector2(move_distance,0)
var velocity = Vector2.ZERO
var state = State.STANDING
var to_player
var player = null
var save_player = null
var dash_direction
var dash_zone = false
var direction = 1
var move_start = true
var target #localização do player
var turret_rotation #rotação da torreta
var turret_posiiton #posição da torreta
var charge = false #usado para inimigos que precisam carregar um ataque
var total_w = 0 #usado para ajustar a função de drop
var drop #recebe a instancia do drop
var count #quantidade de drops do enemy

signal shoot

const SNAP = Vector2(0, 8)

enum State {
	STANDING,
	WALK,
	ATTACK,
	SHOOT,
	DAMAGE,
	DEATH,
	DELAY_AFTER_DAMAGE,
	JUMPING,
	FALL
}


func _ready():
	
	pass


# função para capturar a direção do enemy
func update_velocity():
	
	pass


# estado standing
func standing(delta):
	
	pass


#função que ativa o movimento, pegando a posição do player enquanto ele tiver na visão
func walking(delta):
	
	pass


#estado de pulo
func jump(delta):
	
	pass

#estado de tiro
func shoot():
	
	pass


#função que ativa o ataque a cada 5 segundos
func attack(delta):
	
	pass


#após terminar o ataque para por alguns segundos
func standing_after_damage():
	 
	pass


#transição após o ataque
func standing_after_damage_transition():
	
	pass


func fall(delta):
	
	pass


#verifica se o player ainda ta dentro da hitbox, pa impedir que ele possa encostar no monstro e ficar la sem tomar dano
func player_overlapse():
	
	if player:
		if hit_area.overlaps_body(player):
			player.take_damage_transition(damage, global_position, damage_force)


# estado sofreu dano
func damage(delta):
	
	#ativa as animações de dano e bota uma gravidade
	animation_effets.play("take_damage")
	animation.play("hurt")


#função que recebe o dano e reduz a vida do enemy
func take_damage(damage):
	
	current_life -= damage
	state = State.DAMAGE

	if current_life <= 0:
		drop_power_crystal()
		$".".set_collision_mask(1)
		
		if hit_area:
			hit_area.queue_free()
		if vision_player:
			vision_player.queue_free()
		if dash_area:
			dash_area.queue_free()
			
		state = State.DEATH


#função que ativa a condição de morte
func death(delta):
	
	velocity.x = 0
	animation.play("death")
	animation_effets.play("take_damage")
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)


#função que dropa cristais após a morte do enemy
func drop_power_crystal():
	
	#verifica todo o array e vai somando seus valores de w a cada array, depois chama drop()
	for i in drop_quantity:
		total_w += i.w
		i.w = total_w
	
	count = drop()
	$Timers/DelayDrop.start()


func drop():
	#pega um numero aleatorio em rng e verifica o array, caso o w da posição i do array seja maior que 
	#o numero obtido em rng, esse array é obtido
	randomize()
	var rng = randi() % total_w + 1
	for i in drop_quantity:
		if rng <= i.w:
			return i.quantity


func Drop_timeout():
	
	for i in range(count):
			#emit_signal('power_crystal_drop', pos, drop_value)
			drop = coin_drop.instance()
			drop.global_position = position
			drop.crystal_value = drop_value
			get_tree().get_root().add_child(drop)


func _physics_process(delta):
	
	match state:
		State.STANDING:
			standing(delta)
		State.WALK:
			walking(delta)
		State.ATTACK:
			attack(delta)
		State.DAMAGE:
			damage(delta)
		State.DEATH:
			death(delta)
		State.SHOOT:
			shoot()
		State.DELAY_AFTER_DAMAGE:
			standing_after_damage()
		State.JUMPING:
			jump(delta)
		State.DELAY_AFTER_DAMAGE:
			standing_after_damage()
		State.FALL:
			fall(delta)


func time_bullet_zone():
	
	pass


func start_player_fast_time():
	
	animation.playback_speed /= 10
	walk_speed /= 10
	gravity /= 10
	jump_speed /= 3
	if delay_after_damage:
		delay_after_damage.wait_time *= 2
		delay_after_damage.start()
	if delay_jump:
		delay_jump.wait_time *= 2
		delay_jump.start()
	if dash_delay:
		dash_delay.wait_time *= 2
		dash_delay.start()
	if dash_duration:
		dash_duration.wait_time *= 10
		dash_duration.start()
	if delay_fall:
		delay_fall.wait_time *= 2
	if delay_shoot:
		delay_shoot.wait_time *= 2
		delay_shoot.start()


func stop_player_fast_time():
	
	animation.playback_speed *= 10
	walk_speed *= 10
	gravity *= 10
	jump_speed *= 3
	if delay_after_damage:
		delay_after_damage.wait_time /= 2
		delay_after_damage.start()
	if delay_jump:
		delay_jump.wait_time /= 2
		delay_jump.start()
	if dash_delay:
		dash_delay.wait_time /= 2
		dash_delay.start()
	if dash_duration:
		dash_duration.wait_time /= 10
		dash_duration.start()
	if delay_fall:
		delay_fall.wait_time /= 2
	if delay_shoot:
		delay_shoot.wait_time /= 2
		delay_shoot.start()

#função que verifica se o player entrou no area 2d do enemy e causa dano
func _on_HitBox_body_entered_father(body):
	
	if body.is_in_group("player"):
		player = body
		if body.has_method('take_damage_transition'):
			#passa o dano causado, a posição no momento do dano e a força de impacto do dano
			#essa força de impacto é usada para por exemplo um monstro pequeno apenas causar um leve movimento e um socão
			#muito loko feito por um boss jogar o player na pqp
			body.take_damage_transition(damage, global_position, damage_force)


func _on_HitBox_body_exited_father(body):
	
	if body.is_in_group("player"):
		player = null


#função que ativa alguns estados ou condições após certas animações
func _on_AnimationEnemy_animation_finished_father(anim_name):
	
	if anim_name == "hurt":
		state = State.STANDING
	elif anim_name == "death":
		queue_free()


func _on_AnimationEffects_animation_finished_father(anim_name):
	if anim_name == "take_damage":
		state = State.STANDING

#verifica colisão com a bala no tempo
func _on_HitBox_area_entered_father(area):
	
	if area.name == "TimeBullet":
		walk_speed = walk_speed / 10
		gravity = gravity / 10
		animation.playback_speed = 0.1


#verifica fim da colisão com a bala no tempo
func _on_HitBox_area_exited_father(area):
	
	if area.name == "TimeBullet":
		walk_speed = walk_speed * 10
		gravity = gravity * 10
		animation.playback_speed = 1


#verifica se o player entrou na visão
func _on_VisionPlayer_body_entered_father(body):
	
	if body.is_in_group("player"):
		player = body
		save_player = body


#verifica se o player saiu da visão
func _on_VisionPlayer_body_exited_father(body):
	
	if body.is_in_group("player"):
		player = null


#verifica se o player entrou na zona de dash
func _on_DashZone_body_entered_father(body):
	
	if body.is_in_group("player"):
		dash_zone = true


#verifica se o player saiu da zona de dash
func _on_DashZone_body_exited_father(body):
	
	if body.is_in_group("player"):
		dash_zone = false
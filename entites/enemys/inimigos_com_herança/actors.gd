extends KinematicBody2D

onready var animation = $AnimationEnemy
onready var animation_effets = $AnimationEffects
onready var sprite = $Sprite
onready var hit_box = $HitBox/HitBoxColision
onready var hit_area = $HitBox
onready var vision_player = $VisionPlayer
onready var delay_after_damage = $Timers/DelayAfterDamage
onready var dash_delay = $Timers/DashDelay
onready var dash_duration = $Timers/DashDuration
onready var platform_drop = $FloorColision
onready var platform_wall = $WallColision

export (int) var move_distance = 500
var start_position = position
var end_position = start_position + Vector2(move_distance,0)
export (int) var max_life
export (int) var current_life
export (int) var damage
export (int) var damage_force
export (float) var walk_speed
export (int) var gravity
export (int) var jump_speed
var velocity = Vector2.ZERO
var state = State.STANDING
var to_player
var player = null
var save_player = null
var dash_direction
var dash_zone = false
var direction = 1
var move_start = true
var target
var turret_rotation
var turret_posiiton
var charge = false

signal shoot
signal power_crystal_drop

const SNAP = Vector2(0, 8)

enum State {
	STANDING,
	WALK,
	ATTACK,
	SHOOT,
	DAMAGE,
	DEATH,
	DELAY_AFTER_DAMAGE,
	JUMPING
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


#verifica se o player ainda ta dentro da hitbox, pa impedir que ele possa encostar no monstro e ficar la pra sempre
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
		hit_box.disabled = true
		drop_power_crystal()
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
	
	randomize()
	var count
	var percent = randf()
	var pos = global_position
	
	if (percent > 0.5):
		count = 1
	elif (percent > 0.25):
		count = 2
	elif (percent > 0.10):
		count = 3
	elif (percent > 0.03):
		count = 4
	else:
		count = 5
		
	emit_signal('power_crystal_drop', pos, count)


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


func time_bullet_zone():
	pass


func start_player_fast_time():
	walk_speed = walk_speed / 10
	gravity = gravity / 10
	animation.playback_speed = 0.1


func stop_player_fast_time():
	walk_speed = walk_speed * 10
	gravity = gravity * 10
	animation.playback_speed = 1


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
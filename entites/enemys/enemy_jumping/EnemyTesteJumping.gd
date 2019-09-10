extends KinematicBody2D

onready var animation = $AnimationEnemy
onready var animation_effets = $AnimationEnemy2
onready var sprite = $Sprite
onready var platform_drop = $FloorColision
onready var delay_move = $Timers/DelayMove
onready var move_time = $Timers/MoveTime
onready var move_distance = $Timers/MoveDistance
onready var hit_box = $HitBox/HitBoxColision

export var max_life = 10
export var current_life = 10
export var damage = 10
export var damage_force = 140
export var walk_speed = 150
export var jump_speed = -200
export var gravity = 400

signal power_crystal_drop

enum State {
	STANDING,
	JUMPING,
	DAMAGE,
	DEATH
}

const SNAP = Vector2(0, 8)

var velocity = Vector2.ZERO
var state = State.STANDING
var delay_after_damage = true
var direction = 1
var move_start = true

func _ready():
	
	add_to_group("enemies")


#função que inicia o movimento de pulo assim que o timer chega a 0
func update_velocity():
	
	if delay_move.time_left == 0:
		
		#esse if auxilia para sincronizar os times no inicio do movimento
		if move_start == true:
			move_start = false
			move_distance.start()
			
		move_time.start()
		state = State.JUMPING


#estado onde o enemy fica parado pór alguns segundos após cada movimento
func standing(delta):
	
	velocity.x = 0
	animation.play("idle")
	#quando o timer chegar a 0 troca esse estado pelo estado de pulo
	update_velocity()
	velocity.y += gravity * delta
	velocity = move_and_slide_with_snap(velocity, SNAP, Vector2.UP, true, 4, deg2rad(46), true)
	
	if move_distance.time_left == 0:
		
		move_distance.start()
		direction *= -1
		platform_drop.position.x *= -1
		
		if direction > 0:
			sprite.flip_h = true
		else:
			sprite.flip_h = false


#estado de pulo
func jump(delta):
	
	#quando o timer do movimento chegar a 0 volta ao estado parado
	if move_time.time_left == 0:
		delay_move.start()
		state = State.STANDING
		
	if is_on_floor():
		velocity.y = jump_speed
	
	animation.play("walk")
	velocity.x = walk_speed * direction
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	
	if move_distance.time_left == 0:
		
		move_distance.start()
		direction *= -1
		platform_drop.position.x *= -1
		
		if direction > 0:
			sprite.flip_h = true
		else:
			sprite.flip_h = false


# estado sofreu dano
func damage(delta):
	
	#ativa as animações de dano e bota uma gravidade
	animation_effets.play("take_damage")
	animation.play("hurt")
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)


#função que recebe o dano e reduz a vida do enemy
func take_damage(damage):
	
	current_life -= damage
	state = State.DAMAGE
	move_distance.paused = true
	delay_move.paused = true
	move_distance.paused = true
	
	if current_life <= 0:
		drop_power_crystal()
		state = State.DEATH


#função que ativa a condição de morte
func death(delta):
	
	hit_box.disabled = true
	animation.play("death")
	animation_effets.play("take_damage")
	
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)


#função que dropa cristais após a morte do enemy
func drop_power_crystal():
	
	var pos = global_position
	emit_signal('power_crystal_drop', pos)


func _physics_process(delta):
	
	match state:
		State.STANDING:
			standing(delta)
		State.JUMPING:
			jump(delta)
		State.DAMAGE:
			damage(delta)
		State.DEATH:
			death(delta)


#função que verifica se o player entrou no area 2d do enemy e causa dano
func _on_HitBox_body_entered(body):
	
	if body.is_in_group("player"):
		if body.has_method('take_damage_transition'):
			#passa o dano causado, a posição no momento do dano e a força de impacto do dano
			#essa força de impacto é usada para por exemplo um monstro pequeno apenas causar um leve movimento e um socão
			#muito loko feito por um boss jogar o player na pqp
			body.take_damage_transition(damage, global_position, damage_force)


#função que ativa alguns estados ou condições após certas animações
func _on_AnimationPlayer_animation_finished(anim_name):
	
	if anim_name == "hurt":
		state = State.STANDING
		move_distance.paused = false
		delay_move.paused = false
		move_distance.paused = false
	elif anim_name == "death":
		queue_free()
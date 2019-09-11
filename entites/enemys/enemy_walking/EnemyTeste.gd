extends KinematicBody2D

onready var animation = $AnimationEnemy
onready var animation_effets = $AnimationEnemy2
onready var sprite = $Sprite
onready var platform_drop = $FloorColision
onready var hit_box = $HitBox/HitBoxColision

export var max_life = 10
export var current_life = 10
export var damage = 10
export var damage_force = 140
export var walk_speed = 50
export var gravity = 800

signal power_crystal_drop

enum State {
	STANDING,
	DAMAGE,
	DEATH
}

const SNAP = Vector2(0, 8)

var velocity = Vector2.ZERO
var state = State.STANDING
var delay_after_damage = true
var direction = 1

func _ready():
	
	add_to_group("enemies")


# função para capturar a direção do enemy
func update_velocity():
	
	velocity.x = walk_speed * direction


# estado standing
func standing(delta):
	
	# verifica se o enemy ta parado ou andando
	if velocity.x == 0:
		animation.play("idle")
	else:
		animation.play("walk")
	
	update_velocity()
	velocity.y += gravity * delta
	velocity = move_and_slide_with_snap(velocity, SNAP, Vector2.UP, true, 4, deg2rad(46), true)
	
	if is_on_wall() or not platform_drop.is_colliding():
		
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
	velocity = move_and_slide_with_snap(velocity, SNAP, Vector2.UP, true, 4, deg2rad(46), true)


#função que recebe o dano e reduz a vida do enemy
func take_damage(damage):
	
	current_life -= damage
	state = State.DAMAGE
	
	if current_life <= 0:
		drop_power_crystal()
		state = State.DEATH

#função que ativa a condição de morte
func death():
	
	hit_box.disabled = true
	animation.play("death")
	animation_effets.play("take_damage")


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
		State.DAMAGE:
			damage(delta)
		State.DEATH:
			death()


#função que verifica se o player entrou no area 2d do enemy e causa dano
func _on_HitBox_body_entered(body):
	
	if body.is_in_group("player"):
		if body.has_method('take_damage_transition'):
			#passa o dano causado, a posição no momento do dano e a força de impacto do dano
			#essa força de impacto é usada para por exemplo um monstro pequeno apenas causar um leve movimento e um socão
			#muito loko feito por um boss jogar o player na pqp
			body.take_damage_transition(damage, global_position, damage_force)


func time_bullet_zone():
	pass


#função que ativa alguns estados ou condições após certas animações
func _on_AnimationPlayer_animation_finished(anim_name):
	
	if anim_name == "hurt":
		state = State.STANDING
	elif anim_name == "death":
		queue_free()

func _on_HitBox_area_entered(area):
	
	if area.name == "TimeBullet":
		walk_speed = 5
		gravity = 80


func _on_HitBox_area_exited(area):
	
	if area.name == "TimeBullet":
		walk_speed = 50
		gravity = 800
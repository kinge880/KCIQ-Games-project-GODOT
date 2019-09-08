extends KinematicBody2D

onready var animation = $AnimationPlayer
onready var animation_effets = $AnimationPlayer2
onready var sprite = $Sprite
onready var platform_drop = $RayCast2D

export var max_life = 10
export var current_life = 10
export var damage = 10
export var damage_force = 140

signal power_crystal_drop

enum State {
	STANDING,
	DAMAGE,
	DEATH
}

const WALK_SPEED = 50
const GRAVITY = 800
const SNAP = Vector2(0, 8)

var velocity = Vector2.ZERO
var state = State.STANDING
var delay_after_damage = true
var direction = 1

func _ready():
	add_to_group("enemies")


# função para capturar a direção do Player
func update_velocity():
	
	velocity.x = WALK_SPEED * direction


# estado em pé
func standing(delta):
	
	# verifica se o Player está parado
	if velocity.x == 0:
		animation.play("idle")
	else:
		animation.play("walk")
	
	update_velocity()
	velocity.y += GRAVITY * delta
	velocity = move_and_slide_with_snap(velocity, SNAP, Vector2.UP, true, 4, deg2rad(46), true)
	
	if is_on_wall() or not platform_drop.is_colliding():
		
		direction *= -1
		platform_drop.position.x *= -1
		
		if direction > 0:
			sprite.flip_h = true
		else:
			sprite.flip_h = false


# estado em pé
func damage(delta):
	
	# verifica se o Player está parado
	animation_effets.play("take_damage")
	animation.play("hurt")
	
	velocity.y += GRAVITY * delta


#função que recebe o dano e reduz a vida do player
func take_damage(damage):
	
	current_life -= damage
	print(current_life)
	state = State.DAMAGE
	if current_life <= 0:
		drop_power_crystal()
		state = State.DEATH

#função que ativa a condição de morte, fazer depois
func death():
	
	$Body.disabled = true
	animation.play("death")
	animation_effets.play("take_damage")


func drop_power_crystal():
	
	var pos = global_position
	emit_signal('power_crystal_drop', pos)


func _physics_process(delta):
	
	match state:
		State.STANDING:
			standing(delta)
		State.DAMAGE:
			damage(delta)
		State.DEATH:
			death()


func _on_Area2D_body_entered(body):
	
	if body.is_in_group("player"):
		if body.has_method('take_damage_transition'):
			#passa o dano causado, a posição no momento do dano e a força de impacto do dano
			#essa força de impacto é usada para por exemplo um monstro pequeno apenas causar um leve movimento e um socão
			#muito loko feito por um boss jogar o player na pqp
			body.take_damage_transition(damage, global_position, damage_force)


func _on_AnimationPlayer_animation_finished(anim_name):
	
	if anim_name == "hurt":
		state = State.STANDING
	elif anim_name == "death":
		queue_free()

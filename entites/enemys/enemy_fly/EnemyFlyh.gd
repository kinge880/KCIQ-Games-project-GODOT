extends KinematicBody2D

onready var animation = $AnimationEnemy
onready var animation_effets = $AnimationEnemy2
onready var sprite = $Sprite
onready var hit_box = $HitBox/HitBoxColision

export var max_life = 10
export var current_life = 10
export var damage = 10
export var damage_force = 300
export var walk_speed = 50

signal power_crystal_drop

enum State {
	STANDING,
	WALK,
	ATTACK,
	DAMAGE,
	DEATH
}

var velocity = Vector2.ZERO
var state = State.STANDING
var delay_after_damage = true
var to_player
var player = null
var dash_direction
var dash_zone = false

func _ready():
	
	add_to_group("enemies")


# função para capturar a direção do enemy
func update_velocity():
	
	move_and_slide(to_player * walk_speed)


# estado standing
func standing(delta):
	
	modulate = Color.white
	
	if player:
		state = State.WALK
	elif velocity.x == 0:
		animation.play("idle")


func walking(delta):
	
	if player:
		to_player = player.global_position - global_position
		dash_direction = player.global_position - global_position
		#print(to_player)
		to_player = to_player.normalized()
		move_and_slide(to_player * walk_speed)
		
		if to_player.x < 0:
			animation.play("walk_left")
		elif to_player.x > 0:
			animation.play("walk_rigth")
		
		if dash_zone and $Timers/DashDelay.time_left == 0:
			$Timers/DashDuration.start()
			state = State.ATTACK
	else:
		state = State.STANDING


func attack(delta):
	
	if $Timers/DashDuration.time_left > 0:
		modulate = Color.yellow
		move_and_slide(dash_direction.normalized() * 400)
	else:
		$Timers/DashDelay.start()
		state = State.STANDING

# estado sofreu dano
func damage(delta):
	
	#ativa as animações de dano e bota uma gravidade
	animation_effets.play("take_damage")
	state = State.STANDING

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
		State.WALK:
			walking(delta)
		State.ATTACK:
			attack(delta)
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


func _on_HitBox_area_exited(area):
	
	if area.name == "TimeBullet":
		walk_speed = 50

func _on_VisionPlayer_body_entered(body):
	
	if body.is_in_group("player"):
		player = body

func _on_VisionPlayer_body_exited(body):
	
	if body.is_in_group("player"):
		player = null


func _on_DashZone_body_entered(body):
	
	if body.is_in_group("player"):
		dash_zone = true


func _on_DashZone_body_exited(body):
	
	if body.is_in_group("player"):
		dash_zone = false

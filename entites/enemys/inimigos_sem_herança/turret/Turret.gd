extends KinematicBody2D

onready var animation = $AnimationEnemy
onready var animation_effects = $AnimationEffects
onready var sprite = $Sprite
onready var  turret = $"."

export var max_life = 10
export var current_life = 10
export (float) var walk_speed = 1.0

enum State {
	STANDING,
	MOVE,
	SHOOT,
	DEATH,
	DAMAGE
}

var state = State.STANDING
var delay_after_damage = true
var target
var turret_rotation
var turret_posiiton
var charge = false

signal shoot

const BULLET = preload("res://assets/package/bullets/turret_bullet/turet_bullet.tscn")

func _ready():
	
	turret_rotation = Vector2(1, 0).rotated(turret.global_rotation)
	turret_posiiton = global_position
	add_to_group("enemies")


func move(delta):
	 
	if target:
		var target_dir = (target.global_position - global_position).normalized() 
		var current_dir = Vector2(1, 0).rotated(turret.global_rotation)
		turret.global_rotation = current_dir.linear_interpolate(target_dir, walk_speed * delta ).angle()
		
		if not charge:
			charge = true
			$DelayShoot.start()
			animation.play("charge")
		if $DelayShoot.time_left == 0:
			state = State.SHOOT

func standing(delta):
	
	pass


func shoot():
	
	#dispara uma bala
	emit_signal('shoot', BULLET, global_position, $Sprite/SpawBulet.global_position - global_position)
	animation.play("shoot")
	charge = false
	
	if target:
		state = State.MOVE
	else: 
		state = State.STANDING

# estado sofreu dano
func damage():
	
	#ativa as animações de dano
	animation_effects.play("hurt")


#função que recebe o dano e reduz a vida
func take_damage(damage):
	
	current_life -= damage
	state = State.DAMAGE
	
	if current_life <= 0:
		state = State.DEATH


#função que ativa a condição de morte
func death():
	queue_free()


func _physics_process(delta):
	
	match state:
		State.STANDING:
			standing(delta)
		State.MOVE:
			move(delta)
		State.SHOOT:
			shoot()
		State.DAMAGE:
			damage()
		State.DEATH:
			death()


#função que ativa alguns estados ou condições após certas animações
func _on_AnimationPlayer_animation_finished(anim_name):
	
	if anim_name == "hurt":
		state = State.STANDING
	elif anim_name == "death":
		queue_free()

func _on_DetectArea_body_entered(body):

	if body.is_in_group("player"):
		target = body
		state = State.MOVE


func _on_DetectArea_body_exited(body):
	
	if body == target:
		target = null
		state = State.STANDING


func _on_AnimationEnemy_animation_finished(anim_name):

	if anim_name == "hurt":
		state = State.STANDING
	elif anim_name == "death":
		queue_free()

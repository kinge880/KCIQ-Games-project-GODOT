extends KinematicBody2D

onready var animation = $AnimationEnemy
onready var animation_effets = $AnimationEnemy2
onready var sprite = $Sprite

export var max_life = 100
export var current_life = 100
export var gravity = 50

signal power_crystal_drop

enum State {
	DEFENCE,
	VULNERABLE,
	DAMAGE,
	DEATH
}

const SNAP = Vector2(0, 8)

var velocity = Vector2.ZERO
var state = State.DEFENCE
var delay_after_damage = true
var direction = 1
var move_start = true

func _ready():
	
	add_to_group("enemies")


func defence(delta):
	
	animation.play("idle")
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)

func vulnerable(delta):
	pass


# estado sofreu dano
func damage(delta):
	
	#ativa as animações de dano e bota uma gravidade
	animation_effets.play("take_damage")
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)


#função que recebe o dano e reduz a vida do enemy
func take_damage(damage):
	
	current_life -= damage
	state = State.DAMAGE
	
	if current_life <= 0:
		drop_power_crystal()
		state = State.DEATH


#função que ativa a condição de morte
func death(delta):
	
	queue_free()
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
		count = 20
	elif (percent > 0.25):
		count = 25
	elif (percent > 0.10):
		count = 30
	elif (percent > 0.03):
		count = 35
	else:
		count = 40
		
	emit_signal('power_crystal_drop', pos, count)


func _physics_process(delta):
	
	match state:
		State.DEFENCE:
			defence(delta)
		State.VULNERABLE:
			vulnerable(delta)
		State.DAMAGE:
			damage(delta)
		State.DEATH:
			death(delta)


#função que ativa alguns estados ou condições após certas animações
func _on_AnimationPlayer_animation_finished(anim_name):
	
	pass

func _on_AnimationEnemy2_animation_finished(anim_name):
	
	pass

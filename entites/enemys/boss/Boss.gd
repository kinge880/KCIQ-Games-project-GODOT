extends KinematicBody2D

onready var animation = $AnimationEnemy
onready var animation_effets = $AnimationEnemy2
onready var sprite = $Sprite

export var max_life = 100
export var current_life = 100
export var gravity = 400

signal power_crystal_drop
signal is_death

var is_defence = false

enum State {
	DEFENCE,
	VULNERABLE,
	DAMAGE,
	DEATH
}

var velocity = Vector2.ZERO
var state = State.VULNERABLE

func _ready():
	
	add_to_group("enemies")


func defence(delta):
	
	if not is_defence:
		$TentacleWall/AnimationTentacleWall.play("start")
		is_defence = true
	
	animation.play("idle")
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)


func vulnerable(delta):
	
	if $Timers/VulnerableTime.time_left == 0:
		state = State.DEFENCE
		is_defence = false
	
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)


# estado sofreu dano
func damage(delta):
	
	#ativa as animações de dano e bota uma gravidade
	animation_effets.play("take_damage")
	state = State.VULNERABLE
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
func death():
	
	emit_signal('is_death')
	queue_free()

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
			death()


#função que ativa alguns estados ou condições após certas animações
func _on_Animation_animation_finished(anim_name):
	
	if anim_name == "start":
		$TentacleWall/AnimationTentacleWall.play("idle")

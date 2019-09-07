extends KinematicBody2D

onready var animation = $AnimationPlayer
onready var animation_effets = $AnimationPlayer2
onready var sprite = $Sprite
onready var platform_drop = $RayCast2D

export var max_life = 10
export var current_life = 10
export var damage = 10

signal power_crystal_drop

enum State {
	STANDING
}

const WALK_SPEED = 50
const GRAVITY = 800
const SNAP = Vector2(0, 8)

var velocity = Vector2.ZERO
var state = State.STANDING
var delay_after_damage = true

var direction = 1

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


#função que recebe o dano e reduz a vida do player
func take_damage(damage):
	
	if $DelayAfterDamageTime.time_left ==0:
		current_life -= damage
		print(current_life)
		$DelayAfterDamageTime.start()
		$AnimationPlayer2.play("take_damage")
	if current_life <=0:
		#fazer funções de morte depois
		death()


#função que ativa a condição de morte, fazer depois
func death():
	var pos = global_position
	emit_signal('power_crystal_drop', pos)
	queue_free()


#spawna moeda pra testar
func test_coin():
	
	if Input.is_action_just_pressed("teste_moeda"):
		var mspos = get_global_mouse_position()
		emit_signal('power_crystal_drop', mspos)


func _physics_process(delta):
	
	match state:
		State.STANDING:
			standing(delta)


func _on_Area2D_body_entered(body):
	if body.name == "Player":
		if body.has_method('take_damage'):
			body.take_damage(damage)

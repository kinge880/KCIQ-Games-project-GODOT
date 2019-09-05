extends KinematicBody2D

onready var animation = $AnimationPlayer
onready var dash_delay = $Timers/DashDelay
onready var dash_timer = $Timers/DashTimer
onready var sprite = $Sprite

enum State {
	CROUCHING,
	STANDING,
	DASHING,
	JUMPING
}

const WALK_SPEED = 200
const JUMP_SPEED = -250
const GRAVITY = 800
const SNAP = Vector2(0, 8)

var velocity = Vector2.ZERO

var state = State.STANDING


# função para capturar a direção do Player
func update_velocity():
	
	velocity.x = 0
	
	if Input.is_action_pressed("ui_right"):
		velocity.x += WALK_SPEED
		sprite.flip_h = false
	elif Input.is_action_pressed("ui_left"):
		velocity.x -= WALK_SPEED
		sprite.flip_h = true


# estado em pé
func standing():
	
	update_velocity()
	
	# verifica se o Player está parado
	if velocity.x == 0:
		animation.play("idle")
	else:
		animation.play("walk")
	
	if Input.is_action_pressed("ui_down"):
		state = State.CROUCHING
	
	jump_transition()
	dash_transition()
	
	velocity = move_and_slide_with_snap(velocity, SNAP, Vector2.UP, true, 4, deg2rad(46), true)


# estado pulando
func jumping(delta):
	
	update_velocity()
	
	# verifica se o Player está subindo ou descendo
	if velocity.y < 0:
		animation.play("jump")
	else:
		animation.play("fall")
	
	# limita a altura do pulo
	if Input.is_action_just_released("ui_up"):
		velocity.y = max(velocity.y, -50.0)
	
	velocity.y += GRAVITY * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	
	dash_transition()
	
	if is_on_floor():
		state = State.STANDING


# função para auxiliar a transição para o estado pulando
func jump_transition():
	
	if not is_on_floor():
		state = State.JUMPING
	elif Input.is_action_just_pressed("ui_up"):
		velocity.y = JUMP_SPEED
		state = State.JUMPING


# estado "arrojado" (Google Translate)
func dashing():
	
	animation.play("dash")
	
	var dash_velocity = Vector2(velocity.x * 2, 1)
	dash_velocity = move_and_slide(dash_velocity, Vector2.UP)
	if dash_timer.time_left == 0:
		dash_timer.start()


# função para auxiliar a transição para o estado "arrojado"
func dash_transition():

	# verifica se o delay do dash já acabou e se o player está se movendo 
	if dash_delay.time_left == 0 && velocity.x != 0:
		if Input.is_action_just_pressed("ui_select"):
			state = State.DASHING


# estado agachado
func crouching():
	
	animation.play("crouch")
	
	jump_transition()
	
	if Input.is_action_just_released("ui_down"):
		state = State.STANDING


func _physics_process(delta):
	
	match state:
		State.STANDING:
			standing()
		State.JUMPING:
			jumping(delta)
		State.DASHING:
			dashing()
		State.CROUCHING:
			crouching()


# finaliza o dash
func _on_DashTimer_timeout():
	
	dash_delay.start()
	
	# reseta o movimento do Player após o dash
	velocity = Vector2.ZERO
	
	if not is_on_floor():
		state = State.JUMPING
	else:
		state = State.STANDING

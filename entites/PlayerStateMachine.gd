extends "res://entites/StateMachine.gd"

func _ready():
	add_state("idle")
	add_state("walk")
	add_state("jump")
	add_state("fall")
	call_deferred("set_state", states.idle)

func _physics_process(delta):
	if [states.idle, states.walk].has(state):
		parent.walk_right = Input.is_action_pressed("ui_right")
		parent.walk_left = Input.is_action_pressed("ui_left")
		parent.jump = Input.is_action_just_pressed("ui_up")
		parent.dash = Input.is_action_just_pressed("ui_select")
		parent.atk = Input.is_action_just_pressed("ui_weak_attack")
		#parent.walk_up = Input.is_action_pressed("ui_up")
		#parent.walk_down = Input.is_action_pressed("ui_down") 
		#parent.lower_move = Input.is_action_pressed("ui_down") 
	elif state == states.jump:
		parent.walk_right = Input.is_action_pressed("ui_right")
		parent.walk_left = Input.is_action_pressed("ui_left")
		parent.jump = Input.is_action_just_pressed("ui_up")
		parent.dash = Input.is_action_just_pressed("ui_select")
		parent.atk = Input.is_action_just_pressed("ui_weak_attack")
		parent.jump_stop = Input.is_action_just_released("ui_up")
	elif state == states.fall:
		parent.walk_right = Input.is_action_pressed("ui_right")
		parent.walk_left = Input.is_action_pressed("ui_left")
		parent.jump = Input.is_action_just_pressed("ui_up")
		parent.dash = Input.is_action_just_pressed("ui_select")
		parent.atk = Input.is_action_just_pressed("ui_weak_attack")
	
func get_transitions(delta):
	match state:
		states.idle:
			if not parent.is_on_floor():
				if parent.velocity.y < 0:
					return states.jump
				elif parent.velocity.y > 0:
					return states.fall
			elif parent.velocity.x != 0:
				return states.walk
		
		states.walk:
			if not parent.is_on_floor():
				if parent.velocity.y < 0:
					return states.jump
				elif parent.velocity.y > 0:
					return states.fall
			elif parent.velocity.x == 0:
				return states.idle
		
		states.jump:
			if parent.is_on_floor():
				return states.idle
			elif parent.velocity.y > 0:
				return states.fall
		
		states.fall:
			if parent.is_on_floor():
				return states.idle
			elif parent.velocity.y < 0:
				return states.jump
	
	return null
				
func state_logic(delta):
	parent.apply_gravity(delta)
	parent.apply_movement()
	parent.apply_jump()
	
func enter_state(new_state, old_state):
	match new_state:
		
		states.idle:
			parent.anim.play("idle")
		
		states.walk:
			parent.anim.play("walk")
		
		states.jump:
			parent.anim.play("jump")
		
		states.fall:
			parent.anim.play("fall")

func exit_state(old_state, new_state):
	pass
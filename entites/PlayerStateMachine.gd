extends "res://entites/StateMachine.gd"

#instancia todos os estados dentro do diciorio
func _ready():
	add_state("idle")
	add_state("walk")
	add_state("jump")
	add_state("fall")
	add_state("double_jump")
	add_state("dash")
	add_state("jump_wall")
	add_state("grab_wall")
	call_deferred("set_state", states.idle)

#recebe os inputs baseado no estado atual, permitindo definir qual input deve ser possivel em cada estado
func _physics_process(delta):
	if [states.idle, states.walk, states.fall, states.double_jump].has(state):
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
	elif state == states.grab_wall:
		parent.walk_right = Input.is_action_pressed("ui_right")
		parent.walk_left = Input.is_action_pressed("ui_left")
		parent.released_right = Input.is_action_just_released("ui_right")
		parent.released_left = Input.is_action_just_released("ui_left")
		parent.jump = Input.is_action_just_pressed("ui_up")
		#parent.lower_move = Input.is_action_pressed("ui_down") 

#função que realiza a transição entre os estados as condições de transição devem ser colocadas aqui
func get_transitions(delta):
	match state:
		states.idle:
			if parent.is_on_floor():
				if parent.jump:
					return states.jump
				elif parent.velocity.y > 0:
					return states.fall
			if parent.walk_right or parent.walk_left:
				return states.walk
			elif parent.dash and not parent.dash_delay:
				return states.dash
		
		states.walk:
			if parent.is_on_floor():
				if parent.jump:
					return states.jump
				elif parent.velocity.y > 0:
					return states.fall
			if not parent.walk_right and not parent.walk_left:
				return states.idle
			elif parent.dash and not parent.dash_delay:
				return states.dash
			elif parent.is_on_wall() and not parent.is_on_floor():
				return states.grab_wall
		
		states.jump:
			if parent.is_on_floor():
				return states.idle
			elif not parent.double_jump and parent.jump:
				return states.double_jump
			elif parent.velocity.y > 0:
				return states.fall
			elif parent.dash and not parent.dash_delay:
				return states.dash
			elif parent.is_on_wall() and not parent.is_on_floor():
				return states.grab_wall
		
		states.fall:
			if parent.is_on_floor():
				return states.idle
			elif not parent.double_jump and parent.jump:
				return states.double_jump
			elif parent.dash and not parent.dash_delay:
				return states.dash
			elif parent.is_on_wall() and not parent.is_on_floor():
				return states.grab_wall
		
		states.double_jump:
			if parent.is_on_floor():
				return states.idle
			elif parent.velocity.y > 0:
				return states.fall
			elif parent.dash and not parent.dash_delay:
				return states.dash
			elif parent.is_on_wall() and not parent.is_on_floor():
				return states.grab_wall
		
		states.dash:
			if not parent.dash_time_delay:
				if parent.is_on_floor():
					return states.idle
				elif parent.velocity.y > 0:
					return states.fall
			elif parent.is_on_wall() and not parent.is_on_floor():
				return states.grab_wall
		
		states.grab_wall:
			if parent.is_on_floor():
				return states.idle
			if parent.sprite.flip_h:
				if parent.walk_right:
					return states.jump_wall
			if not parent.sprite.flip_h:
				if parent.walk_left:
					return states.jump_wall
			elif parent.released_right or parent.released_left:
				return states.fall
				
		states.jump_wall:
			if parent.is_on_floor():
				return states.idle
			elif not parent.is_on_floor():
				if parent.velocity.y < 0:
					return states.jump
				elif parent.velocity.y > 0:
					return states.fall
				
	return null
				
#funão auxiliar que permite definir funções que devem estar ativas em todos os estados ou em determinado estado, por exemplo a gravidade.
#que pode se alterar dependendo do estado atual, ou de alguma condição.
func state_logic(delta):
	if parent.is_on_wall():
		parent.apply_gravity_in_wall(delta)
	elif not parent.dash_time_delay:
		parent.apply_gravity(delta)
	parent.apply_movement()

#função que ativa um novo estado, é aqui que todas as mudanças entre os estados são realizadas, como mudar uma animação, ou alternar o valor de uma variavel
func enter_state(new_state, old_state):
	match new_state:
		
		states.idle:
			if old_state == states.grab_wall:
				if parent.sprite.flip_h:
					parent.sprite.flip_h = false
				elif not parent.sprite.flip_h:
					parent.sprite.flip_h = true
			parent.double_jump = false
			parent.air_dash = false
			parent.anim.play("idle")
		
		states.walk:
			parent.anim.play("walk")
		
		states.jump:
			parent.apply_jump()
			parent.anim.play("jump")
		
		states.fall:
			parent.anim.play("fall")
		
		states.double_jump:
			parent.apply_double_jump()
			parent.double_jump = true
			parent.anim.play("double_jump")
		
		states.dash:
			if not parent.air_dash:
				parent.apply_dash()
				parent.anim.play("dash")
				parent.dash_delay = true
				parent.dash_time_delay = true
			parent.air_dash = true
		
		states.grab_wall:
			parent.anim.play("grab_wall")
			
		states.jump_wall:
			parent.apply_jump_wall()
			parent.anim.play("jump")

#função utilizada quando precisamos sair de um estado baseado em algum tipo de condição, pode ser util no futuro
func exit_state(old_state, new_state):
	pass

#timer de duração do dash
func _on_DashTime_timeout():
	parent.speed /= parent.dash_multiplier
	parent.dash_time_delay = false

#timer de delay entre os dashs
func _on_DashDelay_timeout():
	parent.dash_delay = false

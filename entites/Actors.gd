extends KinematicBody2D

export var speed = 200
export var dash_multiplier = 3
export var jump_force = 250
export var lower_force = 250
export var max_life = 100
export var current_life = 100
signal life_changed
var delay_after_damage = false
var walk_right
var walk_left
var walk_up
var walk_down
var jump
var jump_stop
var lower_move
var atk
var atk_delay = false
var dash
var dash_delay = false
var air_dash = false
var atk_count = 0
var double_jump = false
var jump_wall = false
export var gravity = 500
var gravity_aux = 0
var velocity = Vector2()
onready var sprite = $Sprite
onready var anim = $AnimationPlayer

func _physics_process(delta):
	control(delta)
	move_and_slide(velocity)
	
func control(delta):
	pass
	
func take_damage(damage):
	pass

func life_changed():
	pass

func death():
	pass

func _on_AtkTime_timeout():
	atk_delay = false

func _on_DelayAfterDamageTime_timeout():
	pass # Replace with function body.

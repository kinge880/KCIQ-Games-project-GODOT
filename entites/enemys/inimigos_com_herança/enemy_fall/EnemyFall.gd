extends "res://entites/enemys/inimigos_com_herança/actors.gd"

onready var delay_fall = $Timers/DelayFall

func _ready():
	
	add_to_group("enemies")


func fall(delta):
	
	if delay_fall.time_left == 0:
		velocity.y += gravity * delta
		velocity = move_and_slide(velocity, Vector2.UP)
	else:
		animation.play("Pre_fall")


func _on_HitBox_body_entered(body):
	
	if body.is_in_group("player"):
		if body.has_method('take_damage_transition'):
			#passa o dano causado, a posição no momento do dano e a força de impacto do dano
			#essa força de impacto é usada para por exemplo um monstro pequeno apenas causar um leve movimento e um socão
			#muito loko feito por um boss jogar o player na pqp
			body.take_damage_transition(damage, global_position, damage_force)
	
	queue_free()


func _on_FallColision_body_entered(body):
	
	$FallColision.queue_free()
	delay_fall.start()
	state = State.FALL
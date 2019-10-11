extends Node

var day = true
var start = true

func _ready():
	$AnimationPlayer.play("day_cicle")


#Permite ao mapa controlar a bala do tempo
func _on_Player_time_shoot(bullet, _position, _direction):
	var b = bullet.instance()
	add_child(b)
	b._start(_position, _direction)


#Permite ao mapa controlar a bala da torreta
func _on_Turret_shoot(bullet, position, direction):
	
	var b = bullet.instance()
	add_child(b)
	b._start(position, direction)


#caso o player caia em um abismo, ele vai bater nesse fall death e ativar a função de morte
func _on_FallDeath_body_entered(body):
	
	if body.is_in_group("player"):
		get_tree().reload_current_scene()


#controla animações do mapa
func _on_AnimationPlayer_animation_finished(anim_name):
	
	#gerencia o ciclo dia e noite
	if anim_name == "day_cicle" and day:
		$AnimationPlayer.play_backwards("day_cicle")
		day = false
	elif anim_name == "day_cicle" and not day:
		$AnimationPlayer.play("day_cicle")
		day = true
	if anim_name == "start":
		$BossBatle/TentacleWall/AnimationPlayer.play("idle")


#controla os disparos do player
func _on_Player_breath_shoot(bullet, _position, _direction):
	
	var b = bullet.instance()
	add_child(b)
	b._start(_position, _direction)

extends Node

const MOEDA_TESTE = preload("res://assets/package/collectible/PowerCristal.tscn")
var day = true
var start = true

func _ready():
	$AnimationPlayer.play("day_cicle")
	
#Permite ao mapa controlar a bala de gel
func _on_Player_gel_shoot(bullet, _position, _direction):
	
	var b = bullet.instance()
	add_child(b)
	b._start(_position, _direction)


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


#spawna cristais de energia no chão após derrotar um monstro, destruir um grande cristal condensado ou bater em chefes
func _on_Enemy_power_crystal_drop(position, count):
	
	for i in range(count):
		var a = MOEDA_TESTE.instance()   
		a.global_position = position
		add_child(a)


func _on_FallDeath_body_entered(body):
	
	if body.is_in_group("player"):
		get_tree().reload_current_scene()


func _on_AnimationPlayer_animation_finished(anim_name):
	
	if anim_name == "day_cicle" and day:
		$AnimationPlayer.play_backwards("day_cicle")
		day = false
	elif anim_name == "day_cicle" and not day:
		$AnimationPlayer.play("day_cicle")
		day = true
	if anim_name == "start":
		$BossBatle/TentacleWall/AnimationPlayer.play("idle")

func _on_BossBatle_body_entered(body):
	
	if body.is_in_group("player") and start:
		$BossBatle/TentacleWall/AnimationPlayer.play("start")
		$BossBatle/Boss.show()
		
	start = false
extends Node

const MOEDA_TESTE = preload("res://assets/package/collectible/PowerCristal.tscn")

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

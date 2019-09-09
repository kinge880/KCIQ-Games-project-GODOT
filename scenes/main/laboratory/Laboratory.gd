extends Node

const MOEDA_TESTE = preload("res://assets/package/collectible/PowerCristal.tscn")

#Permite ao mapa controlar a bala
func _on_Player_gel_shoot(bullet, _position, _direction):
	var b = bullet.instance()
	add_child(b)
	b._start(_position, _direction)

#spawna cristais de energia no chão após derrotar um monstro, destruir um grande cristal condensado ou bater em chefes
func _on_EnemyJump_power_crystal_drop(position):
	randomize()
	var count = randi() % 5 + 1
	
	for i in range(count):
		var a = MOEDA_TESTE.instance()   
		a.global_position = position
		add_child(a)


func _on_EnemyWalking_power_crystal_drop(position):
	randomize()
	var count = randi() % 5 + 1
	
	for i in range(count):
		var a = MOEDA_TESTE.instance()   
		a.global_position = position
		add_child(a)

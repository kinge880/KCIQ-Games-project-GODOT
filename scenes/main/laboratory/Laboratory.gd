extends Node

#Permite ao mapa controlar a bala
func _on_Player_gel_shoot(bullet, _position, _direction):
	var b = bullet.instance()
	add_child(b)
	b._start(_position, _direction)

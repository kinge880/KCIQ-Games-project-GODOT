extends Node

#habilidades de exploração
export (bool) var dash_obtained
export (bool) var double_jump_obtained
export (bool) var wall_jump_obtained
export (bool) var big_jump_obtained
export (bool) var gliding_obtained

#habilidades ativaveis
export (Array) var hability
#export (Array) var hability = ["BREATH_SHOOT"]
var hability_cont = 0

#atributos
var max_life
var current_life
var max_energy
var current_energy
var big_jump_cost
var gliding_cost
var gel_gun_cost
var time_gun_cost
var reload_power_cristal_cost
var reload_energy_restored
var sword_damage
var fast_time_cost = 1
var time_travel_cost = 20

func _ready():
	pass
	
func get_hability(hability_name):
	
	match hability_name:
		"dash_obtained":
			dash_obtained = true
		"double_jump_obtained":
			double_jump_obtained = true
		"wall_jump_obtained":
			wall_jump_obtained = true
		"big_jump_obtained":
			big_jump_obtained = true
		"gliding_obtained":
			gliding_obtained = true
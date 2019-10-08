extends Area2D

export var speed = 500
export var damage = 20
export var damage_force = 200

var velocity = Vector2()
var body_entered = false

onready var tween = $Tween
onready var life_time = $Lifetime
onready var check_collision = $ColissionCheck

#essa função é chamada assim que a bala é instanciada
func _start(_position, _direction):
	
	position = _position
	rotation = _direction.angle()
	velocity = _direction.normalized()
	
	tween.interpolate_property(self, "speed", speed, 0, 1, Tween.TRANS_QUART, Tween.EASE_IN)
	tween.start()


func _on_Lifetime_timeout():
		#caso não bata em nada, ela some apos um tempo igual a lifetime
		queue_free()


func _process(delta):
	
	var on_wall = check_collision.is_colliding()
	global_position += velocity * delta  * speed
	
	if on_wall:
		collider()

func _on_Bullet_body_entered(body):

	if body.is_in_group("player"):
		if body.has_method('take_damage_transition'):
			#passa o dano causado, a posição no momento do dano e a força de impacto do dano
			#essa força de impacto é usada para por exemplo um monstro pequeno apenas causar um leve movimento e um socão
			#muito loko feito por um boss jogar o player na pqp
			body.take_damage_transition(damage, global_position, damage_force)
	
	collider()

func collider():
	
	$AnimationBullet.play("s")
	life_time.wait_time = 3
	life_time.start()
	check_collision.enabled = false
	$Sprite.hide()
	$Impact.play()


func _on_Impact_finished():
	
	queue_free()

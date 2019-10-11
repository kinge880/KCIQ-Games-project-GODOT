extends Area2D

export var speed = 500
export var damage = 20

var velocity = Vector2()
var body_entered = false

onready var tween = $Tween
onready var life_time = $Lifetime
onready var check_collision = $ColissionCheck

#essa função é chamada assim que a bala é instanciada
func _start(_position, _direction):
	
	position = _position
	velocity = _direction.normalized()
	velocity.y = 0
	
	tween.interpolate_property(self, "speed", speed, 0, 3, Tween.TRANS_QUART, Tween.EASE_IN)
	tween.start()


func _on_Lifetime_timeout():
		#caso não bata em nada, ela some apos um tempo igual a lifetime
		queue_free()


func _process(delta):
	
	var on_wall = check_collision.is_colliding()
	global_position += velocity * delta * speed
	
	if on_wall:
		collider()


func _on_Bullet_body_entered(body):

	if body.is_in_group("enemies"):
			#o body.animation.current_animation é necessario para impedir casos onde continue dropando moedas após a morte
			if body.has_method('take_damage') and body.animation.current_animation != "death":
				body.take_damage(damage)


func collider():
	
	queue_free()
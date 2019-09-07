extends StaticBody2D

export var speed = 500
export var life = 10

var velocity = Vector2()
var body_entered = false

onready var tween = $Tween
onready var life_time = $Lifetime

#essa função é chamada assim que a bala é instanciada
func _start(_position, _direction):
	
	position = _position
	rotation = _direction.angle()
	velocity = _direction.normalized()
	
	tween.interpolate_property(self, "speed", speed, 0, 2, Tween.TRANS_QUART, Tween.EASE_IN)
	tween.start()


func _on_Lifetime_timeout():
		#caso não bata em nada, ela some apos um tempo igual a lifetime
	queue_free()


func _process(delta):
	
	var on_wall = $ColisionWall.is_colliding()
	on_wall = $ColisionWall2.is_colliding()
	
	if on_wall and not body_entered:
		$AnimationBullet.play("grow_up")
		$BulletBody.disabled = false
		
		#adiciona mais tempo de vida
		life_time.wait_time = 5
		life_time.start()
		#para o movimento
		body_entered = true
	
	if not body_entered:
		global_position += velocity * delta  * speed
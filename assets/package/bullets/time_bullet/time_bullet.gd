extends Area2D

export var speed = 500

var velocity = Vector2()
var body_entered = false
var check_body = false

onready var tween = $Tween
onready var life_time = $Lifetime
onready var collider_check = $RayCast2D
onready var animation_bullet = $AnimationBullet

#essa função é chamada assim que a bala é instanciada
func _start(_position, _direction):
	
	position = _position
	velocity = _direction.normalized()
	velocity.y = 0
	
	tween.interpolate_property(self, "speed", speed, 0, 2, Tween.TRANS_QUART, Tween.EASE_IN)
	tween.start()


func _on_Lifetime_timeout():
		#caso não bata em nada, ela some apos um tempo igual a lifetime
	queue_free()


func _process(delta):
	
	var on_wall = collider_check.is_colliding()
	
	if not check_body:
		global_position += velocity * delta  * speed
	if on_wall:
		queue_free()


func _on_Bullet_body_entered(body):

	if body.is_in_group("enemies") or body.is_in_group("obstacle"):
		if body.has_method('time_bullet_zone'):
			check_body = true
			collider_check.enabled = false
			animation_bullet.play("expanse")
			life_time.wait_time = 5
			life_time.start()

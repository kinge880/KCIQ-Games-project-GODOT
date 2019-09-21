extends "res://entites/enemys/inimigos_com_herança/actors.gd"

onready var  turret = $"."

const BULLET = preload("res://assets/package/bullets/turret_bullet/turet_bullet.tscn")

func _ready():
	
	max_life = 10
	current_life = 10
	walk_speed = 1.0
	turret_rotation = Vector2(1, 0).rotated(turret.global_rotation)
	turret_posiiton = global_position
	add_to_group("enemies")


# estado standing
func standing(delta):
	
	if player:
		state = State.WALK


func walking(delta):
	
	if player:
		var target_dir = (player.global_position - global_position).normalized() 
		var current_dir = Vector2(1, 0).rotated(turret.global_rotation)
		turret.global_rotation = current_dir.linear_interpolate(target_dir, walk_speed * delta ).angle()
		
		if not charge:
			charge = true
			$DelayShoot.start()
			animation.play("charge")
		if $DelayShoot.time_left == 0:
			state = State.SHOOT
	else:
		state = State.STANDING


func shoot():
	
	#dispara uma bala
	emit_signal('shoot', BULLET, global_position, $Sprite/SpawBulet.global_position - global_position)
	animation.play("shoot")
	charge = false
	
	if player:
		state = State.WALK
	else: 
		state = State.STANDING


# estado sofreu dano
func damage(delta):
	
	#ativa as animações de dano e bota uma gravidade
	animation_effets.play("take_damage")


#função que recebe o dano e reduz a vida do enemy
func take_damage(damage):
	
	current_life -= damage
	state = State.DAMAGE
	print(current_life)
	if current_life <= 0:
		state = State.DEATH


func _on_VisionPlayer_body_entered(body):
	
	_on_VisionPlayer_body_entered_father(body)


func _on_VisionPlayer_body_exited(body):
	
	_on_VisionPlayer_body_exited_father(body)


func _on_AnimationEffects_animation_finished(anim_name):
	
	_on_AnimationEffects_animation_finished_father(anim_name)


func _on_AnimationEnemy_animation_finished(anim_name):
	
	_on_AnimationEnemy_animation_finished_father(anim_name)
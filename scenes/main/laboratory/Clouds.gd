extends ParallaxLayer

var velocidade = -0.2

func _physics_process(delta):
	
	$".".motion_offset.x += velocidade

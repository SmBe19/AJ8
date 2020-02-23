extends Spatial


func _ready():
	$animation_orbit.play("orbit")
	$animation_rotate.play("rotate")


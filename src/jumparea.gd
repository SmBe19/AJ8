extends Area

export(Vector3) var jumpDir
const JUMP_DIST = 20

func _on_body_entered(body):
	body.move_and_collide(self.jumpDir * JUMP_DIST)

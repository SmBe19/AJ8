extends StaticBody

signal perform_upgrade

func start_upgrade():
	$AnimationPlayer.play("upgrade")

func upgrade_finished():
	$"..".remove_child(self)
	emit_signal("perform_upgrade")

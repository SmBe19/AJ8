extends StaticBody

signal perform_upgrade

func start_upgrade():
	$AnimationPlayer.play("upgrade")
	print("start")

func upgrade_finished():
	$"..".remove_child(self)
	print("finished")

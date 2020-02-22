extends MeshInstance

export(String) var code

func _ready():
	$AnimationPlayer.play(self.code)

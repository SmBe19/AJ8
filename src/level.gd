extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export(Material) var material

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		if child is MeshInstance:
			for i in child.get_surface_material_count():
				child.set_surface_material(i, self.material)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

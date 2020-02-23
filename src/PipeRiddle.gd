extends Spatial

signal puzzle_solved

var camera

func _ready():
	self.camera = $Camera
	self.camera.current = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	print(self.camera.far)

func finish():
	emit_signal("puzzle_solved")
	$"..".remove_child(self)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func shoot_cam_ray():
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_from = self.camera.project_ray_origin(mouse_pos)
	var ray_to = ray_from + self.camera.project_ray_normal(mouse_pos) * self.camera.far
	var space_state = get_world().direct_space_state
	return space_state.intersect_ray(ray_from, ray_to)

func process_input_click(delta):
	if Input.is_action_just_pressed("perform_action"):
		var selection = shoot_cam_ray()
		if selection:
			var obj = selection.collider
			

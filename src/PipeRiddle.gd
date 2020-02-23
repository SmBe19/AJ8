extends Spatial

signal puzzle_solved

var camera

var cell = preload("res://scn/pipe_cell.tscn")

var puzzles = [
	[
		5, 9, 7, 6,
		0, 1, 3, 2,
		2, -1, -1, 2,
		2, -1, 5, 9,
		2, 5, 9, 6,
		4, 9, 6, 4,
	],
	[
		5, 0, 7, 6,
		0, 9, 8, 2,
		2, -1, 10, 3,
		10, 6, 10, 7,
		4, 9, 9, 8,
		-1, -1, 5, 9,
	],
]
var open = [4, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3]
var dirs = [[1, 0], [0, 1], [-1, 0], [0, -1]]
var neighs = [1+2+4+8, 1+4, 2+8, 4+8, 1+8, 1+2, 2+4, 1+2+4, 2+4+8, 1+4+8, 1+2+8]
var status = []
var pipes = []
var current_pipe
var current_pipe_type

func _ready():
	self.camera = $Camera
	self.camera.current = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$"/root/Root/World/Player".should_capture_input = false
	self.build_puzzle()

func build_puzzle():
	randomize()
	self.status.shuffle()
	for y in 6:
		for x in 4:
			var idx = y*4+x
			var new_cell = self.cell.instance()
			new_cell.transform.origin = Vector3(x*2, -1, y*2)
			new_cell.idx = idx
			self.add_child(new_cell)
			if status[idx] >= 0:
				var new_pipe = $pipes.get_child(status[idx]).duplicate()
				new_pipe.transform.origin = Vector3(x*2, 0, y*2)
				self.add_child(new_pipe)
				self.pipes.append(new_pipe)
			else:
				self.pipes.append(null)

func finish():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$"/root/Root/World/Player".should_capture_input = true
	emit_signal("puzzle_solved")
	$"..".remove_child(self)

func check():
	var cnt = []
	for cell in self.status:
		cnt.append(self.open[cell] if cell >= 0 else 0)
	cnt[1] -= 1
	cnt[4] -= 1
	cnt[15] -= 1
	cnt[22] -= 1
	cnt[23] -= 1
	for y in 6:
		for x in 4:
			var idx = y*4+x
			if self.status[idx] < 0:
				continue
			for i in 4:
				var nei = self.neighs[self.status[idx]]
				if nei & (1 << i) > 0:
					var nx = x + dirs[i][0]
					var ny = y + dirs[i][1]
					if nx < 0 or nx >= 4 or ny < 0 or ny >= 6:
						continue
					cnt[ny*4+nx] -= 1
	for y in 6:
		for x in 4:
			if cnt[y*4+x] != 0:
				return
	self.finish()

func _physics_process(delta):
	self.process_input_click(delta)

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
			$audio.play()
			var idx = selection.collider.idx
			var new_current_pipe = null
			var new_current_pipe_type = 0
			if self.pipes[idx]:
				new_current_pipe = self.pipes[idx]
				new_current_pipe_type = self.status[idx]
			if self.current_pipe:
				self.pipes[idx] = self.current_pipe
				var trf = selection.collider.transform
				self.current_pipe.transform.origin = Vector3(trf.origin.x, 0, trf.origin.z)
				self.status[idx] = self.current_pipe_type
			else:
				self.pipes[idx] = null
				self.status[idx] = -1
			self.current_pipe = new_current_pipe
			if new_current_pipe:
				self.current_pipe.global_translate(Vector3(0, 2, 0))
				self.current_pipe_type = new_current_pipe_type
		self.check()
	if self.current_pipe:
		var selection = shoot_cam_ray()
		if selection:
			var trf = selection.collider.transform
			self.current_pipe.transform.origin = Vector3(trf.origin.x, 2, trf.origin.z)

extends KinematicBody

const MOUSE_SENSITIVITY = 0.002
const MAX_SPEED = 10
const MAX_SPEED_FAST = 20
const ACCEL = 4.5
const DEACCEL= 16
const CAM_ANGLE = 70
const LEVEL_ANIMATION_SPEED = 0.5

export(Array, Material) var mat_depth

var old_far = 0
var new_far = 0
var old_correction = 0
var new_correction = 0
var level_progress

var vel = Vector3()
var current_level
var old_current_level

var camera
var helper

var camera_zoomed = false

var code_ui = preload("res://scn/CodeUI.tscn")
var pipe_puzzle = preload("res://scn/PipeRiddle.tscn")

var puzzle_solved = [false, false]
var current_puzzle = 0

func _ready():
	self.camera = $RotationHelper/Camera
	self.helper = $RotationHelper
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	self.set_upgrade_level(0)
	self.level_progress = 1

func _process(delta):
	self.apply_level(delta)

func _physics_process(delta):
	process_input_movement(delta)
	process_input_click(delta)

func process_input_movement(delta):
	
	var dir = Vector3()
	var input_movement_vector = Vector2()
	var cam_xform = camera.get_global_transform()

	if Input.is_action_pressed("move_forward"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("move_backward"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("move_left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("move_right"):
		input_movement_vector.x += 1
	
	# TODO remove this hack
	if Input.is_action_just_pressed("ui_up"):
		self.set_upgrade_level(self.current_level + 1)
	elif Input.is_action_just_pressed("ui_down"):
		self.set_upgrade_level(self.current_level - 1)

	input_movement_vector = input_movement_vector.normalized()
	dir += -cam_xform.basis.z.normalized() * input_movement_vector.y
	dir += cam_xform.basis.x.normalized() * input_movement_vector.x
	dir.y = 0
	dir = dir.normalized()
	
	var target = dir
	if Input.is_action_pressed("move_fast"):
		target *= MAX_SPEED_FAST
	else:
		target *= MAX_SPEED
	
	var accel
	if dir.dot(vel) > 0:
		accel = ACCEL
	else:
		accel = DEACCEL
	vel = vel.linear_interpolate(target, accel * delta)
	vel = move_and_slide(vel, Vector3(0, 1, 0))

func shoot_cam_ray():
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_from = self.camera.project_ray_origin(mouse_pos)
	var ray_to = ray_from + self.camera.project_ray_normal(mouse_pos) * self.camera.far
	var space_state = get_world().direct_space_state
	return space_state.intersect_ray(ray_from, ray_to)

func process_input_click(delta):
	if Input.is_action_just_pressed("perform_action") and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		var selection = shoot_cam_ray()
		if selection:
			var obj = selection.collider
			if obj.is_in_group("upgrade"):
				self.set_upgrade_level(self.current_level + 1)
				obj.start_upgrade()
			elif obj.is_in_group("xor_button"):
				obj.get_node("..").button_pressed(obj)
			elif obj.get_name() == "input_screen_ug":
				show_code_ui(5, "elevator_ug_check")
			elif obj.get_name().find("input_screen_vab") == 0:
				show_code_ui(4, "elevator_vab_check")
			elif obj.get_name() == "input_screen_rocket_bottom":
				show_code_ui(3, "elevator_rocket_bottom_check")
			elif obj.get_name().find("puzzle_") == 0:
				show_puzzle(int(obj.get_name().substr(7, 1)))
			elif obj.get_name() == "input_screen_rocket_top":
				self.transform.origin = $teleports/rocket_bottom.transform.origin
	if current_level >= 4 and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		var selection = shoot_cam_ray()
		if selection:
			var obj = selection.collider
			if obj.get_name() == "space_station" and not self.camera_zoomed:
				$RotationHelper/CameraAnimation.play("ZoomIn")
				self.camera_zoomed = true
		elif self.camera_zoomed:
			$RotationHelper/CameraAnimation.play("ZoomOut")
			self.camera_zoomed = false

func show_puzzle(idx):
	if self.puzzle_solved[idx]:
		return
	self.current_puzzle = idx
	self.old_current_level = self.current_level
	self.set_upgrade_level(3)
	var puzzle = pipe_puzzle.instance()
	puzzle.translate(Vector3(-1000, -1000, -1000))
	puzzle.connect("puzzle_solved", self, "puzzle_solved")
	$"/root/Root".add_child(puzzle)
	
func puzzle_solved():
	self.puzzle_solved[self.current_puzzle] = true
	self.set_upgrade_level(self.old_current_level)

func show_code_ui(length, callback):
	var ui = code_ui.instance()
	ui.code_length = length
	ui.connect("code_entered", self, callback)
	$"/root/Root".add_child(ui)

func elevator_ug_check(code):
	if code == "2AFHB":
		self.transform.origin = $teleports/vab_0.transform.origin

func elevator_vab_check(code):
	if code == "1969":
		self.transform.origin = $teleports/vab_roof.transform.origin
	elif code == "0000":
		self.transform.origin = $teleports/vab_0.transform.origin
	else:
		self.transform.origin = get_node("teleports/vab_" + str(code.hash() % 6)).transform.origin

func elevator_rocket_bottom_check(code):
	if code == "X57":
		self.transform.origin = $teleports/rocket_top.transform.origin

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		self.helper.rotate_x(event.relative.y * MOUSE_SENSITIVITY * -1)
		self.rotate_y(event.relative.x * MOUSE_SENSITIVITY * -1)
		
		var camera_rot = self.helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -CAM_ANGLE, CAM_ANGLE)
		self.helper.rotation_degrees = camera_rot

func apply_level_handle_mat(mat, interp):
	mat.set_shader_param("u_far", lerp(self.old_far, self.new_far, interp))
	mat.set_shader_param("u_dist_correction", lerp(self.old_correction, self.new_correction, interp))

func apply_level(delta):
	self.level_progress = min(1, self.level_progress + delta * LEVEL_ANIMATION_SPEED)
	var interp = smoothstep(0, 1, self.level_progress)
	self.camera.far = lerp(self.old_far, self.new_far, interp)
	for mat in self.mat_depth:
		self.apply_level_handle_mat(mat, interp)
	for node in get_tree().get_nodes_in_group("depth_mat"):
		self.apply_level_handle_mat(node.get_surface_material(0), interp)


func set_upgrade_level(level):
	self.current_level = level
	self.old_far = self.new_far
	self.old_correction = self.new_correction
	self.level_progress = 0
	match level:
		0:
			self.new_far = 5
			self.new_correction = 0.5
		1:
			self.new_far = 15
			self.new_correction = 0.4
		2:
			self.new_far = 40
			self.new_correction = 0.25
		3:
			self.new_far = 200
			self.new_correction = 0.05
		4:
			self.new_far = 1000
			self.new_correction = 0.01

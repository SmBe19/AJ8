extends KinematicBody

const MOUSE_SENSITIVITY = 0.002
const MAX_SPEED = 10
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

var camera
var helper

func _ready():
	camera = $RotationHelper/Camera
	helper = $RotationHelper
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
	target *= MAX_SPEED
	
	var accel
	if dir.dot(vel) > 0:
		accel = ACCEL
	else:
		accel = DEACCEL
	vel = vel.linear_interpolate(target, accel * delta)
	vel = move_and_slide(vel, Vector3(0, 1, 0))

func process_input_click(delta):
	if Input.is_action_just_pressed("perform_action"):
		var mouse_pos = get_viewport().get_mouse_position()
		var ray_from = self.camera.project_ray_origin(mouse_pos)
		var ray_to = ray_from + self.camera.project_ray_normal(mouse_pos) * self.camera.far
		var space_state = get_world().direct_space_state
		var selection = space_state.intersect_ray(ray_from, ray_to)
		if selection:
			if selection.collider.is_in_group("upgrade"):
				self.set_upgrade_level(self.current_level + 1)
				selection.collider.start_upgrade()

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		self.helper.rotate_x(event.relative.y * MOUSE_SENSITIVITY * -1)
		self.rotate_y(event.relative.x * MOUSE_SENSITIVITY * -1)
		
		var camera_rot = self.helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -CAM_ANGLE, CAM_ANGLE)
		self.helper.rotation_degrees = camera_rot

func apply_level(delta):
	self.level_progress = min(1, self.level_progress + delta * LEVEL_ANIMATION_SPEED)
	var interp = smoothstep(0, 1, self.level_progress)
	self.camera.far = lerp(self.old_far, self.new_far, interp)
	for mat in self.mat_depth:
		mat.set_shader_param("u_far", lerp(self.old_far, self.new_far, interp))
		mat.set_shader_param("u_dist_correction", lerp(self.old_correction, self.new_correction, interp))

func set_upgrade_level(level):
	self.current_level = level
	self.old_far = self.new_far
	self.old_correction = self.new_correction
	self.level_progress = 0
	match level:
		0:
			self.new_far = 5
			self.new_correction = 1
		1:
			self.new_far = 15
			self.new_correction = 1
		2:
			self.new_far = 40
			self.new_correction = 0.25
		3:
			self.new_far = 200
			self.new_correction = 0.05
		4:
			self.new_far = 1000
			self.new_correction = 0.01

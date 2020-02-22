extends KinematicBody

const MOUSE_SENSITIVITY = 0.002
const MAX_SPEED = 10
const ACCEL = 4.5
const DEACCEL= 16
const CAM_ANGLE = 50

var vel = Vector3()

var camera
var helper

func _ready():
	camera = $RotationHelper/Camera
	helper = $RotationHelper
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta):
	process_input(delta)

func process_input(delta):
	
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

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		helper.rotate_x(event.relative.y * MOUSE_SENSITIVITY * -1)
		self.rotate_y(event.relative.x * MOUSE_SENSITIVITY * -1)
		
		var camera_rot = helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -CAM_ANGLE, CAM_ANGLE)
		helper.rotation_degrees = camera_rot

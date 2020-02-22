extends Spatial

export(String) var reward_path

var state = 255
var solved = false

func _ready():
	get_node(self.reward_path).translate(Vector3(1000, 1000, 1000))
	for i in 8:
		get_node("xor_light_" + str(i+1) + "/animation").play("Off")

func button_pressed(button):
	button.get_node("animation").play("press")
	match button.get_name():
		"xor_button_1":
			update_state(1)
		"xor_button_2":
			update_state(2)
		"xor_button_3":
			update_state(4)
		"xor_button_4":
			update_state(8)
		"xor_button_5":
			update_state(16)
		"xor_button_6":
			update_state(32)
		"xor_button_7":
			update_state(64 + 128)

func update_state(val):
	var old_state = self.state
	self.state ^= val
	for i in 8:
		var mask = 1 << i
		if old_state & mask > 0 and self.state & mask == 0:
			get_node("xor_light_" + str(i+1) + "/animation").play("Off")
		if old_state & mask == 0 and self.state & mask > 0:
			get_node("xor_light_" + str(i+1) + "/animation").play("On")
	if not self.solved and self.state == 256-1:
		get_node(self.reward_path).translate(Vector3(-1000, -1000, -1000))
		self.solved = true

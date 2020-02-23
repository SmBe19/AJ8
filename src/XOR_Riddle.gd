extends Spatial

export(Array, String) var reward_paths

var state = 0
var solved = false

func _ready():
	for reward_path in self.reward_paths:
		get_node(reward_path).translate(Vector3(1000, 1000, 1000))
	for i in 8:
		get_node("xor_light_" + str(i+1) + "/animation").play("Off")

func button_pressed(button):
	button.get_node("animation").play("press")
	match button.get_name():
		"xor_button_1":
			update_state(1+8+64)
		"xor_button_2":
			update_state(2+32+128)
		"xor_button_3":
			update_state(4+16+32)
		"xor_button_4":
			update_state(8+16+128)
		"xor_button_5":
			update_state(16+64)
		"xor_button_6":
			update_state(32+64+128)
		"xor_button_7":
			update_state(64+128)
		"xor_button_8":
			update_state(128)

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
		for reward_path in self.reward_paths:
			get_node(reward_path).translate(Vector3(-1000, -1000, -1000))
			var animator = get_node(reward_path + "/upgrade/animation")
			if animator:
				animator.play("show")
		self.solved = true

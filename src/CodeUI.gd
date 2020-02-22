extends Control

signal code_entered(code)

export(int) var code_length

var code = ""

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	update_label()

func update_label():
	if self.code.length() == self.code_length:
		emit_signal("code_entered", self.code)
		self.code = ""
		$"..".remove_child(self)
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		return
	var text = self.code
	while text.length() < self.code_length:
		text += "_"
	$bg/vbox/display.text = text.substr(0, 1)
	for i in code_length - 1:
		$bg/vbox/display.text += " " + text.substr(i+1, 1)
		
func press(key):
	self.code += key
	update_label()

func _on_0_button_up():
	self.press("0")

func _on_1_button_up():
	self.press("1")

func _on_2_button_up():
	self.press("2")

func _on_3_button_up():
	self.press("3")

func _on_4_button_up():
	self.press("4")

func _on_5_button_up():
	self.press("5")

func _on_6_button_up():
	self.press("6")

func _on_7_button_up():
	self.press("7")

func _on_8_button_up():
	self.press("8")

func _on_9_button_up():
	self.press("9")

func _on_A_button_up():
	self.press("A")

func _on_B_button_up():
	self.press("B")

func _on_C_button_up():
	self.press("C")

func _on_D_button_up():
	self.press("D")

func _on_E_button_up():
	self.press("E")

func _on_F_button_up():
	self.press("F")

func _on_H_button_up():
	self.press("H")

func _on_J_button_up():
	self.press("J")

func _on_K_button_up():
	self.press("K")

func _on_L_button_up():
	self.press("L")

func _on_X_button_up():
	self.press("X")

func _on_Y_button_up():
	self.press("Y")

func _on_Z_button_up():
	self.press("Z")

func _on_W_button_up():
	self.press("W")

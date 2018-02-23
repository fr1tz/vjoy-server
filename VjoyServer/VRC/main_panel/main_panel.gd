# Written in 2018 by Michael Goldener <mg@wasted.ch>
# To the extent possible under law, the author(s) have dedicated all copyright
# and related and neighboring rights to this software to the public domain
# worldwide. This software is distributed without any warranty.
# You should have received a copy of the CC0 Public Domain Dedication along with
# this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

extends TextureFrame

var host = null

onready var mButtons = get_node("buttons")

func _on_button_pressed(button):
	host.log_notice(button, "pressed")

func _on_vrc_displayed(vrc):
	if vrc == self:
		host.log_notice(self, "displayed")

func _on_vrc_concealed(vrc):
	if vrc == self:
		host.log_notice(self, "concealed")

func _vrc_init(vrc_host_api):
	host = vrc_host_api
	host.connect("vrc_displayed", self, "_on_vrc_displayed")
	host.connect("vrc_concealed", self, "_on_vrc_concealed")
	host.connect("var_changed1", self, "_on_var_changed")
	for i in range(1, 17):
		var button = mButtons.get_child(i-1)
		button.set_label(str(i))
		button.connect("pressed", self, "_on_button_pressed", [button])
		#_on_var_changed("JOYSTICK_STATUS/"+str(i))

func update_joystick_status(joystick_id, status):
	var button = mButtons.get_child(joystick_id-1)
	if status == "free": 
		button.set_led_color(Color(0, 1, 0, 1))
	elif status == "taken":
		button.set_led_color(Color(1, 0, 0, 1))
	else:
		button.set_led_color(Color(0, 0, 0, 1))

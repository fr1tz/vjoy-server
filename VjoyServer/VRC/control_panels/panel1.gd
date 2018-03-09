# Written in 2018 by Michael Goldener <mg@wasted.ch>
# To the extent possible under law, the author(s) have dedicated all copyright
# and related and neighboring rights to this software to the public domain
# worldwide. This software is distributed without any warranty.
# You should have received a copy of the CC0 Public Domain Dedication along with
# this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

extends TextureFrame

var host = null

func _init():
	add_user_signal("send_update")

func _vrc_init(vrc_host_api):
	host = vrc_host_api

func _send_update():
	emit_signal("send_update")

func update_joystick_state(state):
	state.axis_x += get_node("pad1").get_vec().x
	state.axis_y += get_node("pad1").get_vec().y
	if get_node("pad2").is_active():
		state.buttons[0] += 1
	if get_node("pad3").is_active():
		state.buttons[1] += 1

func activate(joystick_id):
	get_node("active_vjoy_label").set_text(str(joystick_id))
	get_node("pad1").connect("activated", self, "_send_update")
	get_node("pad1").connect("deactivated", self, "_send_update")
	get_node("pad2").connect("activated", self, "_send_update")
#	get_node("pad2").connect("deactivated", self, "_send_update")
	get_node("pad3").connect("activated", self, "_send_update")
#	get_node("pad3").connect("deactivated", self, "_send_update")
	set_fixed_process(true)

func deactivate():
	get_node("active_vjoy_label").set_text("--")
	get_node("pad1").disconnect("activated", self, "_send_update")
	get_node("pad1").disconnect("deactivated", self, "_send_update")
	get_node("pad2").disconnect("activated", self, "_send_update")
#	get_node("pad2").disconnect("deactivated", self, "_send_update")
	get_node("pad3").disconnect("activated", self, "_send_update")
#	get_node("pad3").disconnect("deactivated", self, "_send_update")
	set_fixed_process(false)

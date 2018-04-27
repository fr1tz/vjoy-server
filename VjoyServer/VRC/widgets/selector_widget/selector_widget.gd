# Written in 2018 by Michael Goldener <mg@wasted.ch>
# To the extent possible under law, the author(s) have dedicated all copyright
# and related and neighboring rights to this software to the public domain
# worldwide. This software is distributed without any warranty.
# You should have received a copy of the CC0 Public Domain Dedication along with
# this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

extends Node

var host = null

var mVrc = null

func _ready():
	host = get_meta("widget_host_api")
	update_active_joystick_label(mVrc.get_active_joystick())
	get_node("main_canvas/increase_button").connect("pressed", self, "request_next_joystick")
	get_node("main_canvas/decrease_button").connect("pressed", self, "request_prev_joystick")

func init(vrc):
	mVrc = vrc
	var txt = mVrc.get_server_name()
	get_node("main_canvas/server_name_label").set_text(txt)
	update_active_joystick_label(mVrc.get_active_joystick())

func request_next_joystick():
	mVrc.request_next_joystick()

func request_prev_joystick():
	mVrc.request_prev_joystick()

func update_active_joystick_label(joystick_id):
	get_node("main_canvas/joystick_id").set_text(str(joystick_id))

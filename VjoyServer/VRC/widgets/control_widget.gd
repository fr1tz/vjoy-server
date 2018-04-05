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
	get_node("main_canvas/widget/multipad")._widget_init(host)

func update_joystick_state(state):
	var vec = get_node("main_canvas/widget/multipad").get_vec()
	state.axis_x += vec.x
	state.axis_y += vec.y

func init(vrc):
	mVrc = vrc


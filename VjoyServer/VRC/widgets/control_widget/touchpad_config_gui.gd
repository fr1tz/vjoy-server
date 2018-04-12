# Written in 2018 by Michael Goldener <mg@wasted.ch>
# To the extent possible under law, the author(s) have dedicated all copyright
# and related and neighboring rights to this software to the public domain
# worldwide. This software is distributed without any warranty.
# You should have received a copy of the CC0 Public Domain Dedication along with
# this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

extends Control

var mTouchpadConfig = null

func _ready():
	get_node("mode_buttons").connect("button_selected", self, "_mode_button_selected")

func _mode_button_selected(button_idx):
	if button_idx == 0:
		mTouchpadConfig.mode = "stick"
	elif button_idx == 1:
		mTouchpadConfig.mode = "dpad"
	elif button_idx == 2:
		mTouchpadConfig.mode = "button"
	get_meta("widget_root_node").widget_config_changed()

func load_touchpad_config(touchpad_config):
	mTouchpadConfig = touchpad_config
	if mTouchpadConfig.mode == "stick":
		get_node("mode_buttons").set_selected(0)
		get_node("TabContainer/stick_config_gui").load_touchpad_config(touchpad_config)
	elif mTouchpadConfig.mode == "dpad":
		get_node("mode_buttons").set_selected(1)
	elif mTouchpadConfig.mode == "button":
		get_node("mode_buttons").set_selected(2)

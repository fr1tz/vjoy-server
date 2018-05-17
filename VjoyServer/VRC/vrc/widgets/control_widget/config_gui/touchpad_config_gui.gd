# Written in 2018 by Michael Goldener <mg@wasted.ch>
# To the extent possible under law, the author(s) have dedicated all copyright
# and related and neighboring rights to this software to the public domain
# worldwide. This software is distributed without any warranty.
# You should have received a copy of the CC0 Public Domain Dedication along with
# this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

extends Control

var mTouchpadConfig = null

onready var mModeButtons = get_node("mode_buttons")
onready var mTabs = get_node("tabs")

func _ready():
	mModeButtons.connect("button_selected", self, "_mode_button_selected")

func _mode_button_selected(button_idx):
	if button_idx == 0:
		set_mode("stick")
	elif button_idx == 1:
		set_mode("dpad")
	elif button_idx == 2:
		set_mode("button")

func load_touchpad_config(touchpad_config):
	mTouchpadConfig = touchpad_config
	get_node("tabs/stick_config_gui").load_stick_config(touchpad_config.stick_config)
	get_node("tabs/dpad_config_gui").load_dpad_config(touchpad_config.dpad_config)
	get_node("tabs/button_config_gui").load_button_config(touchpad_config.button_config)
	set_mode(mTouchpadConfig.mode)

func set_mode(mode):
	mTouchpadConfig.mode = mode
	if mTouchpadConfig.mode == "stick":
		mModeButtons.set_selected(0)
		mTabs.set_current_tab(0)
	elif mTouchpadConfig.mode == "dpad":
		mModeButtons.set_selected(1)
		mTabs.set_current_tab(1)
	elif mTouchpadConfig.mode == "button":
		mModeButtons.set_selected(2)
		mTabs.set_current_tab(2)
	get_meta("widget_root_node").get_main_gui().reload_widget_config()

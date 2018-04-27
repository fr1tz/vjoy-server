# Written in 2018 by Michael Goldener <mg@wasted.ch>
# To the extent possible under law, the author(s) have dedicated all copyright
# and related and neighboring rights to this software to the public domain
# worldwide. This software is distributed without any warranty.
# You should have received a copy of the CC0 Public Domain Dedication along with
# this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

extends Node

var mVrcHost = null
var mWidgetConfig = null
var mVrc = null

onready var mMainGui = get_node("main_canvas/main_gui")
onready var mConfigGui = get_node("config_canvas/config_gui")

func _ready():
	mVrcHost = get_meta("widget_host_api")
	var basic_config = {
		"num_pads": 1
	}
	var pad1config = {
		"mode": "stick",
		"stick_config": {
			"radius": 32,
			"threshold": 0,
			"x_action": "axis_x",
			"y_action": "axis_y",
		},
		"dpad_config": {
			"radius": 32,
			"threshold": 10
		},
		"button_config": {
			"button_num": 1
		}
	}
	var pad2config = {
		"mode": "stick",
		"stick_config": {
			"radius": 32,
			"threshold": 0,
			"x_action": "axis_x",
			"y_action": "axis_y",
		},
		"dpad_config": {
			"radius": 32,
			"threshold": 10
		},
		"button_config": {
			"button_num": 2
		}
	}
	mWidgetConfig = {
		"basic_config": basic_config,
		"pad_configs": [ pad1config, pad2config ]
	}
	mMainGui.load_widget_config(mWidgetConfig)
	mConfigGui.load_widget_config(mWidgetConfig)
	if mVrc.get_active_joystick() == 0:
		get_main_gui().turn_off()
	else:
		get_main_gui().turn_on()

func update_joystick_state(state):
	get_main_gui().update_joystick_state(state)

func init(vrc):
	mVrc = vrc

#-------------------------------------------------------------------------------
# Common Widget API
#-------------------------------------------------------------------------------

func get_main_gui():
	return mMainGui

func get_config_gui():
	return mConfigGui

func load_widget_config_string(config_string):
	mWidgetConfig = Dictionary()
	if mWidgetConfig.parse_json(config_string) != OK:
		return false
	mMainGui.load_widget_config(mWidgetConfig)
	mConfigGui.load_widget_config(mWidgetConfig)
	return true

func create_widget_config_string():
	return mWidgetConfig.to_json()

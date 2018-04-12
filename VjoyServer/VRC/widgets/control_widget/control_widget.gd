# Written in 2018 by Michael Goldener <mg@wasted.ch>
# To the extent possible under law, the author(s) have dedicated all copyright
# and related and neighboring rights to this software to the public domain
# worldwide. This software is distributed without any warranty.
# You should have received a copy of the CC0 Public Domain Dedication along with
# this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

extends Node

var host = null
var mWidgetConfig = null
var mVrc = null

onready var mMainGui = get_node("main_canvas/main_gui")
onready var mConfigGui = get_node("config_canvas/config_gui")

func _ready():
	host = get_meta("widget_host_api")
	var config
	var pad0config = {
		"mode": "stick",
		"threshold": 10,
		"radius": 40,
		"x": "axis_z",
		"y": "axis_z_rot"
	}
	var pad1config = {
		"mode": "dpad",
		"threshold": 32,
		"radius": 64
	}
	var pad2config = {
		"mode": "button",
		"threshold": 0,
		"radius": 16,
		"x+": "axis_z+",
		"x-": "axis_z-",
		"y+": "slider1+",
		"y-": "slider1-"
	}
	config = {
		"num_pads": 1,
		"pad_configs": [ pad0config, pad1config ]
	}
	load_widget_config(config)

func update_joystick_state(state):
	var vec = get_node("main_canvas/widget/touchpad").get_vec()
	state.axis_x += vec.x
	state.axis_y += vec.y

func init(vrc):
	mVrc = vrc

func load_widget_config(widget_config):
	mWidgetConfig = widget_config
	mMainGui.load_widget_config(widget_config)
	mConfigGui.load_widget_config(widget_config)

func create_widget_config():
	return null

func get_config_gui():
	return mConfigGui

func widget_config_changed():
	print(mWidgetConfig)
	mMainGui.load_widget_config(mWidgetConfig)

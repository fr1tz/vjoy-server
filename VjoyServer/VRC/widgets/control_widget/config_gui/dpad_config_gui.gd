# Written in 2018 by Michael Goldener <mg@wasted.ch>
# To the extent possible under law, the author(s) have dedicated all copyright
# and related and neighboring rights to this software to the public domain
# worldwide. This software is distributed without any warranty.
# You should have received a copy of the CC0 Public Domain Dedication along with
# this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

extends Control

var mDPadConfig = null

onready var mRadiusSlider = get_node("radius/slider")
onready var mRadiusValueLabel = get_node("radius/value_label")
onready var mThresholdSlider = get_node("threshold/slider")
onready var mThresholdValueLabel = get_node("threshold/value_label")
onready var mXAxisButtons = get_node("x/axis_buttons")
onready var mYAxisButtons = get_node("y/axis_buttons")

func _ready():
	mRadiusSlider.connect("value_changed", self, "_radius_changed")
	mThresholdSlider.connect("value_changed", self, "_threshold_changed")

func _radius_changed(new_value):
	mRadiusValueLabel.set_text(str(new_value))
	mDPadConfig.radius = new_value
	get_meta("widget_root_node").get_main_gui().reload_widget_config()

func _threshold_changed(new_value):
	mThresholdValueLabel.set_text(str(new_value))
	mDPadConfig.threshold = new_value
	get_meta("widget_root_node").get_main_gui().reload_widget_config()

func load_dpad_config(dpad_config):
	mDPadConfig = dpad_config
	mRadiusSlider.set_value(dpad_config.radius)
	mThresholdSlider.set_value(dpad_config.threshold)

# Written in 2018 by Michael Goldener <mg@wasted.ch>
# To the extent possible under law, the author(s) have dedicated all copyright
# and related and neighboring rights to this software to the public domain
# worldwide. This software is distributed without any warranty.
# You should have received a copy of the CC0 Public Domain Dedication along with
# this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

extends Control

var mTouchpadConfig = null

onready var mRadiusSlider = get_node("radius/slider")
onready var mRadiusValueLabel = get_node("radius/value_label")
onready var mThresholdSlider = get_node("threshold/slider")
onready var mThresholdValueLabel = get_node("threshold/value_label")

func _ready():
	mRadiusSlider.connect("value_changed", self, "_radius_changed")
	mThresholdSlider.connect("value_changed", self, "_threshold_changed")

func _radius_changed(new_value):
	mRadiusValueLabel.set_text(str(new_value))
	mTouchpadConfig.radius = new_value
	get_meta("widget_root_node").widget_config_changed()

func _threshold_changed(new_value):
	mThresholdValueLabel.set_text(str(new_value))
	mTouchpadConfig.threshold = new_value
	get_meta("widget_root_node").widget_config_changed()

func load_touchpad_config(touchpad_config):
	mTouchpadConfig = touchpad_config
	mRadiusSlider.set_value(touchpad_config.radius)
	mThresholdSlider.set_value(touchpad_config.threshold)

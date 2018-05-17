# Written in 2018 by Michael Goldener <mg@wasted.ch>
# To the extent possible under law, the author(s) have dedicated all copyright
# and related and neighboring rights to this software to the public domain
# worldwide. This software is distributed without any warranty.
# You should have received a copy of the CC0 Public Domain Dedication along with
# this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

extends Control

var mStickConfig = null

onready var mRadiusSlider = get_node("radius/slider")
onready var mRadiusValueLabel = get_node("radius/value_label")
onready var mThresholdSlider = get_node("threshold/slider")
onready var mThresholdValueLabel = get_node("threshold/value_label")
onready var mXAxisButtons = get_node("x/axis_buttons")
onready var mYAxisButtons = get_node("y/axis_buttons")

func _ready():
	mRadiusSlider.connect("value_changed", self, "_radius_changed")
	mThresholdSlider.connect("value_changed", self, "_threshold_changed")
	mXAxisButtons.connect("button_selected", self, "_xaxis_button_selected")
	mYAxisButtons.connect("button_selected", self, "_yaxis_button_selected")

func _radius_changed(new_value):
	mRadiusValueLabel.set_text(str(new_value))
	mStickConfig["radius"] = new_value
	get_meta("widget_root_node").get_main_gui().reload_widget_config()

func _threshold_changed(new_value):
	mThresholdValueLabel.set_text(str(new_value))
	mStickConfig["threshold"] = new_value
	get_meta("widget_root_node").get_main_gui().reload_widget_config()

func _xaxis_button_selected(button_idx):
	if button_idx == 0:
		mStickConfig["x_action"] = "axis_x"
	elif button_idx == 1:
		mStickConfig["x_action"] = "axis_y"
	elif button_idx == 2:
		mStickConfig["x_action"] = "axis_z"
	elif button_idx == 3:
		mStickConfig["x_action"] = "axis_x_rot"
	elif button_idx == 4:
		mStickConfig["x_action"] = "axis_y_rot"
	elif button_idx == 5:
		mStickConfig["x_action"] = "axis_z_rot"
	get_meta("widget_root_node").get_main_gui().reload_widget_config()

func _yaxis_button_selected(button_idx):
	if button_idx == 0:
		mStickConfig["y_action"] = "axis_x"
	elif button_idx == 1:
		mStickConfig["y_action"] = "axis_y"
	elif button_idx == 2:
		mStickConfig["y_action"] = "axis_z"
	elif button_idx == 3:
		mStickConfig["y_action"] = "axis_x_rot"
	elif button_idx == 4:
		mStickConfig["y_action"] = "axis_y_rot"
	elif button_idx == 5:
		mStickConfig["y_action"] = "axis_z_rot"
	get_meta("widget_root_node").get_main_gui().reload_widget_config()

func load_stick_config(stick_config):
	mStickConfig = stick_config
	mRadiusSlider.set_value(mStickConfig.radius)
	mThresholdSlider.set_value(mStickConfig.threshold)
	var x_action = mStickConfig.x_action
	if x_action == "axis_x":
		mXAxisButtons.set_selected(0)
	elif x_action == "axis_y":
		mXAxisButtons.set_selected(1)
	elif x_action == "axis_z":
		mXAxisButtons.set_selected(2)
	elif x_action == "axis_x_rot":
		mXAxisButtons.set_selected(3)
	elif x_action == "axis_y_rot":
		mXAxisButtons.set_selected(4)
	elif x_action == "axis_z_rot":
		mXAxisButtons.set_selected(5)
	var y_action = mStickConfig.y_action
	if y_action == "axis_x":
		mYAxisButtons.set_selected(0)
	elif y_action == "axis_y":
		mYAxisButtons.set_selected(1)
	elif y_action == "axis_z":
		mYAxisButtons.set_selected(2)
	elif y_action == "axis_x_rot":
		mYAxisButtons.set_selected(3)
	elif y_action == "axis_y_rot":
		mYAxisButtons.set_selected(4)
	elif y_action == "axis_z_rot":
		mYAxisButtons.set_selected(5)

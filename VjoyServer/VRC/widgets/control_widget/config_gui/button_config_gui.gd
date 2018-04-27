# Written in 2018 by Michael Goldener <mg@wasted.ch>
# To the extent possible under law, the author(s) have dedicated all copyright
# and related and neighboring rights to this software to the public domain
# worldwide. This software is distributed without any warranty.
# You should have received a copy of the CC0 Public Domain Dedication along with
# this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

extends Control

var mButtonConfig = null

onready var mButtonNumSlider = get_node("button_num/slider")
onready var mButtonNumValueLabel = get_node("button_num/value_label")

func _ready():
	mButtonNumSlider.connect("value_changed", self, "_button_num_changed")

func _button_num_changed(new_value):
	mButtonNumValueLabel.set_text(str(new_value))
	mButtonConfig["button_num"] = new_value
	get_meta("widget_root_node").get_main_gui().reload_widget_config()

func load_button_config(button_config):
	mButtonConfig = button_config
	mButtonNumSlider.set_value(mButtonConfig.button_num)

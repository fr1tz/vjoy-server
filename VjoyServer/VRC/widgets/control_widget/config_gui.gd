# Written in 2018 by Michael Goldener <mg@wasted.ch>
# To the extent possible under law, the author(s) have dedicated all copyright
# and related and neighboring rights to this software to the public domain
# worldwide. This software is distributed without any warranty.
# You should have received a copy of the CC0 Public Domain Dedication along with
# this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

extends Panel

var mWidgetConfig = null

func _ready():
	get_node("num_pads_buttons").connect("button_selected", self, "_num_pads_button_selected")
	get_node("configure_pad1_button").connect("pressed", self, "configure_pad", [0])
	get_node("configure_pad2_button").connect("pressed", self, "configure_pad", [1])

func _num_pads_button_selected(button_idx):
	if button_idx == 0:
		mWidgetConfig.num_pads = 1
		get_node("configure_pad1_button").set_hidden(false)
		get_node("configure_pad2_button").set_hidden(true)
	elif button_idx == 1:
		mWidgetConfig.num_pads = 2
		get_node("configure_pad2_button").set_hidden(false)
		get_node("configure_pad2_button").set_hidden(false)
	get_meta("widget_root_node").get_main_gui().reload_widget_config()

func configure_pad(pad_idx):
	var touchpad_config = mWidgetConfig.pad_configs[pad_idx]
	get_node("touchpad_config_gui").load_touchpad_config(touchpad_config)
	get_node("touchpad_config_gui").set_hidden(false)

func load_widget_config(widget_config):
	mWidgetConfig = widget_config
	if mWidgetConfig.num_pads == 1:
		get_node("num_pads_buttons").set_selected(0)
	elif mWidgetConfig.num_pads == 2:
		get_node("num_pads_buttons").set_selected(1)

func go_back():
	if get_node("touchpad_config_gui").is_hidden():
		return false
	get_node("touchpad_config_gui").set_hidden(true)
	return true

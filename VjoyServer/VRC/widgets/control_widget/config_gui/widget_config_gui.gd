# Written in 2018 by Michael Goldener <mg@wasted.ch>
# To the extent possible under law, the author(s) have dedicated all copyright
# and related and neighboring rights to this software to the public domain
# worldwide. This software is distributed without any warranty.
# You should have received a copy of the CC0 Public Domain Dedication along with
# this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

extends Panel

var mWidgetConfig = null

onready var mConfigurePad1Button = get_node("configure_pad1_button")
onready var mConfigurePad2Button = get_node("configure_pad2_button")
onready var m2PadsButton = get_node("2_pads_button")
onready var mTouchpadConfigGui = get_node("touchpad_config_gui")

func _ready():
	m2PadsButton.connect("pressed", self, "_num_pads_changed")
	mConfigurePad1Button.connect("pressed", self, "configure_pad", [0])
	mConfigurePad2Button.connect("pressed", self, "configure_pad", [1])

func _num_pads_changed():
	if m2PadsButton.is_pressed():
		mWidgetConfig.basic_config.num_pads = 2
	else:
		mWidgetConfig.basic_config.num_pads = 1
	load_widget_config(mWidgetConfig)
	get_meta("widget_root_node").get_main_gui().reload_widget_config()

func configure_pad(pad_idx):
	if pad_idx == 0:
		mConfigurePad1Button.set_pressed(true)
		mConfigurePad2Button.set_pressed(false)
	else:
		mConfigurePad1Button.set_pressed(false)
		mConfigurePad2Button.set_pressed(true)
	var touchpad_config = mWidgetConfig.pad_configs[pad_idx]
	mTouchpadConfigGui.load_touchpad_config(touchpad_config)

func load_widget_config(widget_config):
	mWidgetConfig = widget_config
	if mWidgetConfig.basic_config.num_pads == 1:
		mConfigurePad2Button.set_hidden(true)
	elif mWidgetConfig.basic_config.num_pads == 2:
		mConfigurePad2Button.set_hidden(false)
	configure_pad(0)

func go_back():
	return false

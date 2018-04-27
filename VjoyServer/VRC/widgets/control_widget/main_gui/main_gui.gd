# Written in 2018 by Michael Goldener <mg@wasted.ch>
# To the extent possible under law, the author(s) have dedicated all copyright
# and related and neighboring rights to this software to the public domain
# worldwide. This software is distributed without any warranty.
# You should have received a copy of the CC0 Public Domain Dedication along with
# this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

extends ReferenceFrame

var mWidgetConfig = null
var mOn = false

onready var mPad0 = get_node("pad0")
onready var mPad1 = get_node("pad1")
onready var mPad2 = get_node("pad2")

func reload_widget_config():
	load_widget_config(mWidgetConfig)

func load_widget_config(widget_config):
	mWidgetConfig = widget_config
	if mWidgetConfig.basic_config.num_pads == 2:
		get_node("textures/dsplit").set_hidden(false)
		mPad1.load_touchpad_config(mWidgetConfig.pad_configs[0])
		mPad2.load_touchpad_config(mWidgetConfig.pad_configs[1])
	else:
		get_node("textures/dsplit").set_hidden(true)
		get_node("textures/stick").set_hidden(mWidgetConfig.pad_configs[0].mode != "stick")
		mPad0.load_touchpad_config(mWidgetConfig.pad_configs[0])
	if mOn:
		turn_on()

func update_joystick_state(state):
	if mWidgetConfig.basic_config.num_pads == 2:
		mPad1.update_joystick_state(state)
		mPad2.update_joystick_state(state)
	else:
		mPad0.update_joystick_state(state)

func turn_on():
	mOn = true
	for tex in get_node("textures").get_children():
		tex.set_modulate(Color(1, 1, 1, 1))
	if mWidgetConfig.basic_config.num_pads == 2:
		mPad0.set_hidden(true)
		mPad1.set_hidden(false)
		mPad2.set_hidden(false)
	else:
		mPad0.set_hidden(false)
		mPad1.set_hidden(true)
		mPad2.set_hidden(true)

func turn_off():
	mOn = false
	for tex in get_node("textures").get_children():
		tex.set_modulate(Color(0.2, 0.2, 0.2, 1))
	mPad0.set_hidden(true)
	mPad1.set_hidden(true)
	mPad2.set_hidden(true)


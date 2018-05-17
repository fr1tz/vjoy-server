# Written in 2018 by Michael Goldener <mg@wasted.ch>
# To the extent possible under law, the author(s) have dedicated all copyright
# and related and neighboring rights to this software to the public domain
# worldwide. This software is distributed without any warranty.
# You should have received a copy of the CC0 Public Domain Dedication along with
# this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

extends ReferenceFrame

var mWidgetConfig = null
var mOn = false

onready var mPads = get_node("pads")

func _ready():
	connect("resized", self, "reload_widget_config")

func _create_pad():
	var pad = load("res://vrc/widgets/control_widget/main_gui/touchpad.tscn").instance()
	pad.set_meta("widget_host_api", get_meta("widget_host_api"))
	return pad

func reload_widget_config():
	load_widget_config(mWidgetConfig)

func load_widget_config(widget_config):
	mWidgetConfig = widget_config
	for c in mPads.get_children():
		mPads.remove_child(c)
		c.queue_free()
	if mWidgetConfig.basic_config.num_pads == 2:
		var margin = 5
		var verts
		var pad
		verts = Vector2Array()
		verts.append(Vector2(margin, margin))
		verts.append(Vector2(get_size().x-margin, get_size().y-margin))
		verts.append(Vector2(margin, get_size().y-margin))
		pad = _create_pad()
		pad.set_polygon(verts)
		pad.load_touchpad_config(mWidgetConfig.pad_configs[0])
		mPads.add_child(pad)
		verts = Vector2Array()
		verts.append(Vector2(margin, margin))
		verts.append(Vector2(get_size().x-margin, margin))
		verts.append(Vector2(get_size().x-margin, get_size().y-margin))
		pad = _create_pad()
		pad.set_polygon(verts)
		pad.load_touchpad_config(mWidgetConfig.pad_configs[1])
		mPads.add_child(pad)
	else:
		var margin = 5
		var verts = Vector2Array()
		verts.append(Vector2(margin, margin))
		verts.append(Vector2(get_size().x-margin, margin))
		verts.append(Vector2(get_size().x-margin, get_size().y-margin))
		verts.append(Vector2(margin, get_size().y-margin))
		var pad = _create_pad()
		pad.set_polygon(verts)
		pad.load_touchpad_config(mWidgetConfig.pad_configs[0])
		mPads.add_child(pad)
	if mOn:
		turn_on()

func update_joystick_state(state):
	for pad in mPads.get_children():
		pad.update_joystick_state(state)

func turn_on():
	mOn = true
	for pad in mPads.get_children():
		pad.turn_on()

func turn_off():
	mOn = false
	for pad in mPads.get_children():
		pad.turn_off()

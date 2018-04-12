# Written in 2018 by Michael Goldener <mg@wasted.ch>
# To the extent possible under law, the author(s) have dedicated all copyright
# and related and neighboring rights to this software to the public domain
# worldwide. This software is distributed without any warranty.
# You should have received a copy of the CC0 Public Domain Dedication along with
# this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

extends Panel

var mWidgetConfig = null

func load_widget_config(widget_config):
	mWidgetConfig = widget_config
	if widget_config.num_pads == 2:
		get_node("pad0").set_hidden(true)
		get_node("pad1").set_hidden(false)
		get_node("pad2").set_hidden(false)
		get_node("pad_dsplit").set_hidden(false)
		get_node("pad1").load_touchpad_config(widget_config.pad_configs[0])
		get_node("pad2").load_touchpad_config(widget_config.pad_configs[1])
	else:
		get_node("pad0").set_hidden(false)
		get_node("pad1").set_hidden(true)
		get_node("pad2").set_hidden(true)
		get_node("pad_dsplit").set_hidden(true)
		get_node("pad0").load_touchpad_config(widget_config.pad_configs[0])

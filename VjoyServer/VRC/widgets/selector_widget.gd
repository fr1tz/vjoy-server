# Written in 2018 by Michael Goldener <mg@wasted.ch>
# To the extent possible under law, the author(s) have dedicated all copyright
# and related and neighboring rights to this software to the public domain
# worldwide. This software is distributed without any warranty.
# You should have received a copy of the CC0 Public Domain Dedication along with
# this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

extends Node

var host = null

var mVrc = null

func _ready():
	host = get_meta("widget_host_api")

func init(vrc, server_name):
	mVrc = vrc
	var txt = server_name + " vJoy Selector"
	get_node("main_canvas/widget/server_name_label").set_text(txt)

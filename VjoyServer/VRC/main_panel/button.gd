# Written in 2018 by Michael Goldener <mg@wasted.ch>
# To the extent possible under law, the author(s) have dedicated all copyright
# and related and neighboring rights to this software to the public domain
# worldwide. This software is distributed without any warranty.
# You should have received a copy of the CC0 Public Domain Dedication along with
# this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

extends Control

func _init():
	add_user_signal("pressed")

func _ready():
	get_node("button").connect("button_down", self, "_button_down")
	get_node("button").connect("button_up", self, "_button_up")

func set_label(text):
	get_node("label").set_text(text)

func set_led_color(color):
	get_node("led_glow").set_modulate(color)

func _button_down():
	get_node("up").hide()
	emit_signal("pressed")

func _button_up():
	get_node("up").show()

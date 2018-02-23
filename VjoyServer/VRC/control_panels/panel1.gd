# Written in 2018 by Michael Goldener <mg@wasted.ch>
# To the extent possible under law, the author(s) have dedicated all copyright
# and related and neighboring rights to this software to the public domain
# worldwide. This software is distributed without any warranty.
# You should have received a copy of the CC0 Public Domain Dedication along with
# this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

extends TextureFrame

var host = null

func _vrc_init(vrc_host_api):
	host = vrc_host_api
	host.connect("vrc_displayed", self, "_on_vrc_displayed")
	host.connect("vrc_concealed", self, "_on_vrc_concealed")
	host.log_notice(self, "ready")

func set_joystick_id(joystick_id):
	get_node("active_vjoy_label").set_text(str(joystick_id))
	if int(joystick_id) == 0:
		get_node("pad1").disconnect("activated", self, "_send_update")
		get_node("pad1").disconnect("deactivated", self, "_send_update")
		get_node("pad2").disconnect("activated", self, "_send_update")
		get_node("pad2").disconnect("deactivated", self, "_send_update")
		get_node("pad3").disconnect("activated", self, "_send_update")
		get_node("pad3").disconnect("deactivated", self, "_send_update")
		set_fixed_process(false)
	else:
		get_node("pad1").connect("activated", self, "_send_update")
		get_node("pad1").connect("deactivated", self, "_send_update")
		get_node("pad2").connect("activated", self, "_send_update")
		get_node("pad2").connect("deactivated", self, "_send_update")
		get_node("pad3").connect("activated", self, "_send_update")
		get_node("pad3").connect("deactivated", self, "_send_update")
		set_fixed_process(true)

func update_joystick_state(state):
	state.axis_x += get_node("pad1").get_vec().x
	state.axis_y += get_node("pad1").get_vec().y
	if get_node("pad2").is_active():
		state.buttons[0] += 1
	if get_node("pad3").is_active():
		state.buttons[1] += 1

#func _canvas_input(event):
	#print("joypad: _input(): ", event)
#	get_node("joypad1")._canvas_input(event)
#	get_node("joypad2")._canvas_input(event)
#	get_node("Polygon2D")._canvas_input(event)
#	get_node("canvas").update()
#	return
#	if !is_visible():
#		return
#	var touchscreen = (event.type == InputEvent.SCREEN_TOUCH || event.type == InputEvent.SCREEN_DRAG)
#	var touch = (event.type == InputEvent.SCREEN_TOUCH || event.type == InputEvent.MOUSE_BUTTON)
#	var drag = (event.type == InputEvent.SCREEN_DRAG || event.type == InputEvent.MOUSE_MOTION)
#	if !touch && !drag:
#		return
#	var index = 0
#	if touchscreen:
#		index = event.index
#	var move = {
#		type = 0,
#		vec = null
#	}
#	var joypad = null
#	if index == mJoypads[0].mIndex:
#		joypad = mJoypads[0]
#	elif index == mJoypads[1].mIndex:
#		joypad = mJoypads[1]
#	if joypad != null:
#		if touch && !event.pressed:
#			joypad.mIndex = -1
#			move.type = 2
#			move.vec = null
#		else:
#			joypad.mTarget = event.pos - get_global_pos()
#			move.type = 1
#	elif touch && event.pressed && get_node("joypads_area").get_global_rect().has_point(event.pos):
#		if mJoypads[0].mIndex == -1:
#			joypad = mJoypads[0]
#		elif mJoypads[1].mIndex == -1:
#			joypad = mJoypads[1]
#		joypad.mIndex = index
#		joypad.mCenter = event.pos - get_global_pos()
#		joypad.mTarget = joypad.mCenter
#		move.type = 1
#	if move.type == 1:
#		move.vec = ((mTarget-mCenter)/get_size()).rotated(-PI/2)
#		#print(get_name(), ":", move.vec)

	#emit_signal("new_move", self, move)


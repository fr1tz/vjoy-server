# Written in 2018 by Michael Goldener <mg@wasted.ch>
# To the extent possible under law, the author(s) have dedicated all copyright
# and related and neighboring rights to this software to the public domain
# worldwide. This software is distributed without any warranty.
# You should have received a copy of the CC0 Public Domain Dedication along with
# this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

extends TextureFrame

const SEND_UPDATE_INTERVAL = 0.064

var host = null

var mMainPanel = null
var mControlPanels = null
var mControllerId = 0
var mJoystickId = 0
var mSendUpdateCountdown = SEND_UPDATE_INTERVAL

func _call_vrc_init(node, vrc_host_api):
	if node.has_method("_vrc_init"):
		node._vrc_init(vrc_host_api)
	for c in node.get_children():
		_call_vrc_init(c, vrc_host_api)

func _ready():
	mMainPanel = get_node("main_panel")
	mControlPanels = get_node("control_panels")
	var vrc_host_api = get_meta("vrc_host_api")
	if vrc_host_api == null:
		vrc_host_api = get_node("/root/vrc_host_api_test_stub")
		vrc_host_api.set_var("CONTROLLER_ID", "123")
		vrc_host_api.set_var("SEND_UPDATE_ADDR", "udp!127.0.0.1!1234")
		vrc_host_api.set_var("ACTIVE_JOYSTICK_ID", "1")
		for i in range(1, 17):
			var status = [ "free", "taken", "" ]
			vrc_host_api.set_var(("JOYSTICK_STATUS/"+str(i)), status[randi() % 3])
	_call_vrc_init(self, vrc_host_api)

func _fixed_process(delta):
	mSendUpdateCountdown -= delta
	if mSendUpdateCountdown <= 0:
		_send_update()

func _vrc_init(vrc_host_api):
	host = vrc_host_api
	get_node("log_sender").start(host, "$0", "[L][NL][S][NL][Cfs][0]", [" | "," ¦ "," , "])
	_on_var_changed("CONTROLLER_ID")
	_on_var_changed("SEND_UPDATE_ADDR")
	_on_var_changed("ACTIVE_JOYSTICK_ID")
	for i in range(1, 17): _on_var_changed("JOYSTICK_STATUS/"+str(i))
	host.connect("var_changed1", self, "_on_var_changed")
	host.set_icon(get_node("icon").get_texture())
	host.show_region(get_node("main_panel").get_rect())
	host.log_notice(self, "ready")

func _on_var_changed(var_name):
	host.log_debug(self, ["_on_var_changed():", var_name])
	var var_value = host.get_var(var_name)
	if var_name == "CONTROLLER_ID":
		mControllerId = int(var_value)
		print(mControllerId)
	elif var_name == "ACTIVE_JOYSTICK_ID":
		mJoystickId = int(var_value)
		if mJoystickId > 0 && mJoystickId <= 16:
			activate_joystick()
		else:
			deactivate_joystick()
	elif var_name.begins_with("JOYSTICK_STATUS/"):
		var f = var_name.split("/")
		var joystick_id = int(f[f.size()-1])
		var status = var_value
		mMainPanel.update_joystick_status(joystick_id, status)

func _encode_int7(val):
	var negative = val < 0
	val = int(abs(val)) 
	var byte = val & 127
	if negative:
		byte = byte | 128
	var b2 = val & 0xFF
	return byte

func _encode_int15(val):
	var negative = val < 0
	val = int(abs(val)) 
	var b1 = val >> 8
	if negative:
		b1 = b1 | 128
	var b2 = val & 0xFF
	var bytes = RawArray()
	bytes.append(b1)
	bytes.append(b2)
	return bytes

func _encode_uint16(val):
	var b1 = val >> 8
	var b2 = val & 0xFF
	var bytes = RawArray()
	bytes.append(b1)
	bytes.append(b2)
	return bytes

func _send_update():
	if mJoystickId == 0:
		return
	var state = {
		"axis_x": 0,
		"axis_y": 0,
		"axis_z": 0,
		"axis_x_rot": -1,
		"axis_y_rot": -1,
		"axis_z_rot": 0,
		"slider1": -1,
		"slider2": -1,
		"buttons": []
	}
	state.buttons.resize(16)
	for i in range(0, 16):
		state.buttons[i] = 0
	for panel in mControlPanels.get_children():
		panel.update_joystick_state(state)
	var axis_x = int((clamp(state.axis_x, -1, 1)*127))
	var axis_y = int((clamp(state.axis_y, -1, 1)*127))
	var axis_z = int((clamp(state.axis_z, -1, 1)*127))
	var axis_x_rot = int((clamp(state.axis_x_rot, -1, 1)*127))
	var axis_y_rot = int((clamp(state.axis_y_rot, -1, 1)*127))
	var axis_z_rot = int((clamp(state.axis_z_rot, -1, 1)*127))
	var slider1 = int((clamp(state.slider1, -1, 1)*127))
	var slider2 = int((clamp(state.slider2, -1, 1)*127))
	var buttons1 = 0
	for i in range(0, 8):
		buttons1 |= int(clamp(state.buttons[i], 0, 1)) << i
	var buttons2 = 0
	for i in range(0, 8):
		buttons2 |= int(clamp(state.buttons[8+i], 0, 1)) << i
	var data = RawArray()
	data.append(10)
	data.append_array(_encode_uint16(mControllerId))
	data.append(_encode_int7(axis_x))
	data.append(_encode_int7(axis_y))
	data.append(_encode_int7(axis_z))
	data.append(_encode_int7(axis_x_rot))
	data.append(_encode_int7(axis_y_rot))
	data.append(_encode_int7(axis_z_rot))
	data.append(_encode_int7(slider1))
	data.append(_encode_int7(slider2))
	data.append(buttons1)
	data.append(buttons2)
	data.append(0)
	data.append(0)
	data.append(0)
	host.send(data, host.get_var("SEND_UPDATE_ADDR"))
	mSendUpdateCountdown = SEND_UPDATE_INTERVAL

func go_back():
	if host.get_var("ACTIVE_JOYSTICK_ID") != "0":
		deactivate_joystick()
		return true
	return false

func activate_joystick():
	#mJoystickPanel.set_joystick_id(mJoystickId)
	set_fixed_process(true)
	host.show_region(mControlPanels.get_child(0).get_rect())
	host.log_notice(self, "joystick enabled")

func deactivate_joystick():
	set_fixed_process(false)
	host.show_region(get_node("main_panel").get_rect())
	host.log_notice(self, "joystick disabled")

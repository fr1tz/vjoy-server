extends Node

var host = null

func _vrc_init(vrc_host_api):
	host = vrc_host_api

func encode_int7(val):
	var negative = val < 0
	val = int(abs(val)) 
	var byte = val & 127
	if negative:
		byte = byte | 128
	var b2 = val & 0xFF
	return byte

func encode_int15(val):
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

func encode_uint16(val):
	var b1 = val >> 8
	var b2 = val & 0xFF
	var bytes = RawArray()
	bytes.append(b1)
	bytes.append(b2)
	return bytes

func send_joystick_state(state, to):
	var controller_id = int(state.controller_id)
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
	data.append_array(encode_uint16(controller_id))
	data.append(encode_int7(axis_x))
	data.append(encode_int7(axis_y))
	data.append(encode_int7(axis_z))
	data.append(encode_int7(axis_x_rot))
	data.append(encode_int7(axis_y_rot))
	data.append(encode_int7(axis_z_rot))
	data.append(encode_int7(slider1))
	data.append(encode_int7(slider2))
	data.append(buttons1)
	data.append(buttons2)
	data.append(0)
	data.append(0)
	data.append(0)
	host.send(data, to)

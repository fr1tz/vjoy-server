# Written in 2018 by Michael Goldener <mg@wasted.ch>
# To the extent possible under law, the author(s) have dedicated all copyright
# and related and neighboring rights to this software to the public domain
# worldwide. This software is distributed without any warranty.
# You should have received a copy of the CC0 Public Domain Dedication along with
# this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

extends TextureFrame

const SEND_UPDATE_INTERVAL = 0.05

var host = null

var mServerName = ""
var mControllerId = 0
var mActiveJoystickId = 0
var mJoystickStatus = []
var mSendUpdateCountdown = SEND_UPDATE_INTERVAL
var mMainPanel = null
var mControlPanel = null
var mSelectorWidgets = []
var mControlWidgets = []

func _call_vrc_init(node, vrc, vrc_host_api):
	if node.has_method("_vrc_init"):
		node._vrc_init(vrc, vrc_host_api)
	for c in node.get_children():
		_call_vrc_init(c, vrc, vrc_host_api)

func _ready():
	for i in range(0, 16):
		mJoystickStatus.push_back("unknown")
	mMainPanel = get_node("main_panel")
	mControlPanel = get_node("control_panel")
	var vrc_host_api = get_meta("vrc_host_api")
	if vrc_host_api == null:
		vrc_host_api = get_node("/root/vrc_host_api_test_stub")
		vrc_host_api.set_var("SERVER_NAME", "[No Server]")
		vrc_host_api.set_var("CONTROLLER_ID", "123")
		vrc_host_api.set_var("SEND_UPDATE_ADDR", "udp!127.0.0.1!1234")
		vrc_host_api.set_var("ACTIVE_JOYSTICK_ID", "1")
		for i in range(1, 17):
			var status = [ "free", "taken", "" ]
			vrc_host_api.set_var(("JOYSTICK_STATUS/"+str(i)), status[randi() % 3])
	_call_vrc_init(self, self, vrc_host_api)

func _vrc_init(vrc, vrc_host_api):
	host = vrc_host_api
	get_node("log_sender").start(host, "$0", "[L][NL][S][NL][Cfs][0]", [" | "," ¦ "," , "])
	mControlPanel.connect("send_update", self, "_send_priority_update")
	_on_var_changed("SERVER_NAME")
	_on_var_changed("CONTROLLER_ID")
	_on_var_changed("SEND_UPDATE_ADDR")
	_on_var_changed("ACTIVE_JOYSTICK_ID")
	for i in range(1, 17): 
		_on_var_changed("JOYSTICK_STATUS/"+str(i))
	host.connect("var_changed1", self, "_on_var_changed")
	host.add_widget_factory("vjoy.selector", "vJoy Selector", self, "create_selector_widget")
	host.add_widget_factory("vjoy.control", "vJoy Control", self, "create_control_widget")
#	var product_id_prefix = mServerName.to_lower()+".vjoy."
#	host.add_widget_factory(product_id_prefix+"selector", mServerName+" vJoy Selector", self, "create_selector_widget")
#	host.add_widget_factory(product_id_prefix+"control", mServerName+" vJoy Control", self, "create_control_widget")
	host.set_icon(get_node("icon").get_texture())
	host.show_region(get_node("main_panel").get_rect())
	host.log_notice(self, "ready")

func _fixed_process(delta):
	mSendUpdateCountdown -= delta
	if mSendUpdateCountdown <= 0:
		_send_update()

func _on_var_changed(var_name):
	host.log_debug(self, ["_on_var_changed():", var_name])
	var var_value = host.get_var(var_name)
	if var_name == "SERVER_NAME":
		var server_name = var_value
		_on_server_name_changed(server_name)
	elif var_name == "CONTROLLER_ID":
		var controller_id = int(var_value)
		_on_controller_id_changed(controller_id)
	elif var_name == "ACTIVE_JOYSTICK_ID":
		var active_joystick_id = int(var_value)
		if is_valid_joystick_id(active_joystick_id):
			_on_joystick_acquired(active_joystick_id)
		else:
			_on_joystick_released()
	elif var_name.begins_with("JOYSTICK_STATUS/"):
		var f = var_name.split("/")
		var joystick_id = int(f[f.size()-1])
		var status = var_value
		_on_joystick_status_changed(joystick_id, status)

func _on_server_name_changed(server_name):
	mServerName = server_name

func _on_controller_id_changed(controller_id):
	mControllerId = controller_id

func _on_joystick_acquired(active_joystick_id):
	mActiveJoystickId = active_joystick_id
	mControlPanel.activate(mActiveJoystickId)
	for widget in mSelectorWidgets:
		widget.update_active_joystick_label(mActiveJoystickId)
	for widget in mControlWidgets:
		widget.get_main_gui().turn_on()
	set_fixed_process(true)
	host.show_region(get_node("regions/control1").get_rect(), true)
	host.log_notice(self, "controls_activated")

func _on_joystick_released():
	mActiveJoystickId = 0
	mControlPanel.deactivate()
	for widget in mSelectorWidgets:
		widget.update_active_joystick_label(0)
	for widget in mControlWidgets:
		widget.get_main_gui().turn_off()
	set_fixed_process(false)
	host.show_region(get_node("regions/main").get_rect(), false)
	host.log_notice(self, "controls_deactivated")

func _on_joystick_status_changed(joystick_id, status):
	if !is_valid_joystick_id(joystick_id):
		return
	mJoystickStatus[joystick_id-1] = status
	mMainPanel.update_joystick_status(joystick_id, status)

func _send_priority_update():
	call_deferred("_send_update")

func _send_update():
	if mActiveJoystickId == 0:
		return
	var state = {
		"controller_id": mControllerId,
		"axis_x": 0,
		"axis_y": 0,
		"axis_z": 0,
		"axis_x_rot": 0,
		"axis_y_rot": 0,
		"axis_z_rot": 0,
		"slider1": 0,
		"slider2": 0,
		"buttons": []
	}
	state.buttons.resize(16)
	for i in range(0, 16):
		state.buttons[i] = 0
	mControlPanel.update_joystick_state(state)
	for widget in mControlWidgets:
		widget.update_joystick_state(state)
	var addr = host.get_var("SEND_UPDATE_ADDR")
	get_node("net").send_joystick_state(state, addr)
	mSendUpdateCountdown = SEND_UPDATE_INTERVAL

func go_back():
	if mActiveJoystickId != 0:
		request_joystick(0)
		return true
	return false

func request_joystick(joystick_id):
	host.log_notice(self, "joystick_request " + str(joystick_id))

func is_valid_joystick_id(joystick_id):
	return joystick_id >= 1 && joystick_id <= 16

func get_server_name():
	return mServerName

func get_active_joystick():
	return mActiveJoystickId

func get_joystick_status(joystick_id):
	if !is_valid_joystick_id(joystick_id):
		return "unknown"
	return mJoystickStatus[joystick_id-1]

func request_next_joystick():
	var next_available_joystick_id = 0
	var id = mActiveJoystickId + 1
	while is_valid_joystick_id(id):
		var status = get_joystick_status(id)
		if status == "free" || status == "taken":
			next_available_joystick_id = id
			break
		id += 1
	request_joystick(next_available_joystick_id)

func request_prev_joystick():
	var next_available_joystick_id = 0
	var id = mActiveJoystickId - 1
	while is_valid_joystick_id(id):
		var status = get_joystick_status(id)
		if status == "free" || status == "taken":
			next_available_joystick_id = id
			break
		id -= 1
	request_joystick(next_available_joystick_id)

func create_selector_widget():
	var widget = load("res://widgets/selector_widget/selector_widget.tscn").instance()
	widget.init(self)
	mSelectorWidgets.push_back(widget)
	return widget

func create_control_widget():
	var widget = load("res://widgets/control_widget/control_widget.tscn").instance()
	widget.init(self)
	mControlWidgets.push_back(widget)
	return widget

# Copyright © 2017, 2018 Michael Goldener <mg@wasted.ch>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

extends Node

var mVrc = null
var mCanvasInputNodes = []
var mVariables = {}
var mVhcpExtensions = {}

func _init():
	add_user_signal("new_log_entry3")
	add_user_signal("vrc_displayed")
	add_user_signal("vrc_concealed")
	add_user_signal("var_changed1")
	add_user_signal("var_changed2")
	add_user_signal("var_changed3")
	set_process_input(true)

func _emit_new_log_entry3(source_node, level, content):
	emit_signal("new_log_entry3", source_node, level, content)

func _emit_vrc_displayed(vrc):
	emit_signal("vrc_displayed", vrc)

func _emit_vrc_concealed(vrc):
	emit_signal("vrc_concealed", vrc)

func _emit_var_changed1(var_name):
	emit_signal("var_changed1", var_name)

func _emit_var_changed2(var_name, new_value):
	emit_signal("var_changed2", var_name, new_value)

func _emit_var_changed3(var_name, new_value, old_value):
	emit_signal("var_changed3", var_name, new_value, old_value)

func _ready():
	for c in get_node("/root").get_children():
		if c.get_name() != "vrc_host_api_test_stub":
			mVrc = c
			break

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_FOCUS_IN:
		emit_signal("vrc_displayed", mVrc)
	elif what == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
		emit_signal("vrc_concealed", mVrc)

func _input(event):
	for node in mCanvasInputNodes:
		node._canvas_input(event)

func _log(source_node, level, content):
	var source_path = get_path_from_node(source_node)
	var vrchost_log_entry = level+":"+source_path+":"+str(content)
	emit_signal("new_log_entry3", source_node, level, content)
	print(vrchost_log_entry)

func add_vrc(var_name, vrc_name):
	return ""

func disable_canvas_input(node):
	mCanvasInputNodes.remove(node)

func enable_canvas_input(node):
	if mCanvasInputNodes.has(node):
		return
	mCanvasInputNodes.append(node)

func get_node_from_path(path_string):
	var self_path = str(get_path())
	if !path_string.begins_with(self_path):
		return null
	var relative_path_string = path_string.right(self_path.length())
	return get_node(relative_path_string)

func get_path_from_node(node):
	if !node.is_inside_tree():
		return null
	return str(node.get_path()).replace("/root/","vrchost/")

func get_var(name):
	name = name.to_upper()
	if mVariables.has(name):
		return mVariables[name]
	return ""

func get_var_list():
	return ""

func log_debug(source, msg):
	_log(source, "debug", msg)
	return ""

func log_notice(source, msg):
	_log(source, "notice", msg)
	return ""

func log_error(source, msg):
	_log(source, "error", msg)
	return ""

func send(data, to, from = null):
	return ""

func set_icon(image):
	return ""

func set_var(name, value):
	name = name.to_upper()
	var old_value = ""
	if mVariables.has(name):
		if mVariables[name] == value:
			return
		old_value = mVariables[name]
	mVariables[name] = value
	emit_signal("var_changed1", name)
	emit_signal("var_changed2", name, value)
	emit_signal("var_changed3", name, value, old_value)
	return ""

func show_region(rect, fullscreen = false):
	return ""

func add_vhcp_extension(command_name, object, method):
	if mVhcpExtensions.has(command_name):
		return "VHCP extension " + command_name + " already exists"
	mVhcpExtensions[command_name] = funcref(object, method)
	return ""

func has_vhcp_extension(command_name):
	return mVhcpExtensions.has(command_name)

func remove_vhcp_extension(command_name):
	if !mVhcpExtensions.has(command_name):
		return "VHCP extension " + command_name + " does not exist"
	mVhcpExtensions.erase(command_name)
	return ""

func call_vhcp_extension(command_name, cmdline, source):
	if !mVhcpExtensions.has(command_name):
		return "VHCP extension " + command_name + " does not exist"
	mVhcpExtensions[command_name].call_func(cmdline, source) 

func get_vhcp_extensions():
	var extensions = []
	for command_name in mVhcpExtensions:
		extensions.append(command_name)
	return extensions

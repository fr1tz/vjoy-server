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

extends ColorFrame

var mVrcHostApi = null
var mVrc = null
var mVariables = Dictionary()
var mCanvasInputNodes = []

func _init():
	add_user_signal("vrc_displayed")
	add_user_signal("vrc_concealed")
	add_user_signal("new_log_entry3")
	add_user_signal("var_changed1")
	add_user_signal("var_changed2")
	add_user_signal("var_changed3")
	mVrcHostApi = preload("pseudo_vrc_host_api.gd").new(self)

func _ready():
	var mVrc = load("res://vrc.tscn").instance()
	_set_meta_recursive(mVrc, "vrc_host_api", mVrcHostApi)
	_set_meta_recursive(mVrc, "vrc_root_node", mVrc)
	get_node("vrc_canvas").add_child(mVrc)

func _set_meta_recursive(node, name, value):
	node.set_meta(name, value)
	for c in node.get_children():
		_set_meta_recursive(c, name, value)

func _notification(what):
	if mVrc == null:
		return
	if what == MainLoop.NOTIFICATION_WM_FOCUS_IN:
		emit_signal("vrc_displayed", mVrc)
	elif what == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
		emit_signal("vrc_concealed", mVrc)

func _input(event):
	for node in mCanvasInputNodes:
		node._canvas_input(event)

func add_log_entry(source_node, level, content):
	var source_path = get_path_from_node(source_node)
	var vrchost_log_entry = level+":"+source_path+":"+str(content)
	emit_signal("new_log_entry3", source_node, level, content)
	print(vrchost_log_entry)

func add_vrc(var_name, vrc_name):
	return ""

func add_widget_factory(product_id, product_name, object, create_widget_method):
#	if mWidgetFactoryTaskIds.has(product_id):
#		var task_id = mWidgetFactoryTaskIds[product_id]
#		rcos.change_task(task_id, {
#			"product_name": product_name,
#			"create_widget_func": funcref(object, create_widget_method)
#		})
#	else:
#		var task_id = rcos.add_task({
#			"type": "widget_factory",
#			"product_id": product_id,
#			"product_name": product_name,
#			"create_widget_func": funcref(object, create_widget_method)
#		})
#		mWidgetFactoryTaskIds[product_id] = task_id
	return true

func remove_widget_factory(product_id):
#	if !mWidgetFactoryTaskIds.has(product_id):
#		return true
#	var task_id = mWidgetFactoryTaskIds[product_id]
#	rcos.remove_task(task_id)
#	mWidgetFactoryTaskIds.erase(product_id)
	return true

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

func get_variable(name):
	name = name.to_upper()
	if mVariables.has(name):
		return mVariables[name]
	return ""

func get_var_list():
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

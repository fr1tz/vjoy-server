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

var host = null

var mReceiverAddress = "$0"
var mMsgFormat = "[L] [S] [Cfs][NL]"
var mContentFieldSeparators = []

func start(vrchost_api, address = null, format = null, field_separators = null):
	host = vrchost_api
	if address != null:
		mReceiverAddress = address
	if format != null:
		mMsgFormat = format
	if field_separators != null:
		mContentFieldSeparators = field_separators
	host.connect("new_log_entry3", self, "_on_new_log_entry")

func _on_new_log_entry(source_node, level, content):
#	if !(source_node == self && content[0] == "_on_new_log_entry()"):
#		host.log_debug(self, ["_on_new_log_entry()", level, source_node, content])
	if level == "debug":
		return
	if typeof(content) != TYPE_ARRAY:
		content = [content]
	var source_path = host.get_path_from_node(source_node)
	_send_log_message(level, source_node, source_path, content)

func _send_log_message(level, source_node, source_path, content):
	if !(source_node == self && content[0] == "_send_log_message()"):
		host.log_debug(self, ["_send_log_message()", level, source_node, source_path, content])
	var input = mMsgFormat
	var L = level       # string
	var S = source_path # string
	var C = content     # array
	var data = RawArray()
	while input != "":
		var c = input[0]
		if c != "[":
			data.append_array(c.to_ascii())
			input = input.right(1)
		else:
			var idx = input.find("]", 1)
			if idx == -1:
				data.append(c)
				input = input.right(1)
				continue
			var s = input.substr(1, idx-1)
			var x
			if s == "L":
				x = L
			elif s == "S":
				x = S
			elif s == "NL":
				x = "\n"
			elif s == "Cfs":
				x = _join_array_tree(C, mContentFieldSeparators, false)
			elif s == "Cxfs":
				x = _join_array_tree(C, mContentFieldSeparators, true)
			elif s.is_valid_integer():
				x = int(s)
			if typeof(x) == TYPE_STRING:
				data.append_array(x.to_ascii())
			elif typeof(x) == TYPE_INT:
				data.append(x)
			input = input.right(idx+1)
	#prints("data:", data.get_string_from_ascii())
	host.send(data, mReceiverAddress)

func _join_array_tree(array, fsl, ef = false, depth = 0):
	var s = ""
	var fs
	if depth < fsl.size():
		fs = fsl[depth]
	else:
		fs = fsl.back()
	for i in range(0, array.size()):
		var e = array[i]
		if typeof(e) == TYPE_ARRAY:
			s += join_array_tree(e, fsl, ef, depth+1)
		elif typeof(e) == TYPE_STRING:
			if ef:
				e = e.xml_escape()
			s += e
		else:
			continue
		if i < array.size()-1:
			s += fs
	return s

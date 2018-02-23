tool
extends EditorPlugin

const IGNORE_DIRS = [ ".", "..", "addons", "vrc_host_api_test_stub" ]
const IGNORE_EXT = [ "cfg", "ico", "xcf" ]

var mButton

func _enter_tree():
	mButton = preload("res://addons/vrc_exporter/button.tscn").instance()
	mButton.connect("pressed", self, "create_vrc_file")
	add_control_to_container(CONTAINER_TOOLBAR, mButton)

func _exit_tree():
	mButton.free()

func create_vrc_file():
	var project_name = Globals.get("application/name").replace(" ", "")
	var output_file_path = Globals.globalize_path("res://../"+project_name+".tar") 
	prints("Writing VRC file", output_file_path)
	var file = File.new()
	if file.open(output_file_path, File.WRITE) != 0:
		prints("Unable to open file", output_file_path)
	process_dir("res://", file)
	var empty_block = RawArray()
	while empty_block.size() < 512:
		empty_block.append(0)
	file.store_buffer(empty_block)
	file.store_buffer(empty_block)
	file.close()

func process_dir(dir_path, output_file):
	if !dir_path.ends_with("/"):
		dir_path += "/"
	var dir = Directory.new()
	if dir.open(dir_path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while (file_name != ""):
			if dir.current_is_dir():
				if !IGNORE_DIRS.has(file_name):
					process_dir(dir_path + file_name, output_file)
			else:
				var ext = file_name.extension()
				if !IGNORE_EXT.has(ext):
					add_object(dir_path + file_name, output_file)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

func add_object(file_path, output_file):
	prints("Adding", file_path)
	var f = File.new()
	if f.open(file_path, File.READ) != 0:
		prints("Unable to open file", file_path)
		return
	var data = f.get_buffer(f.get_len())
	f.close()
	var name = file_path.right(6)
	var size = data.size()
	var mode_string = "0100777"
	var uid_string = "0000000"
	var gid_string = "0000000"
	var size_string = ("%11o" % size).replace(" ", "0")
	var mod_string = ("%11o" % OS.get_unix_time()).replace(" ", "0")
	var checksum_string = "        "
	var type_string = "0"
	var object = RawArray()
	# Write header
	object.append_array(name.to_ascii())
	while object.size() < 100: object.append(0)
	object.append_array(mode_string.to_ascii()); object.append(0)
	object.append_array(uid_string.to_ascii()); object.append(0)
	object.append_array(gid_string.to_ascii()); object.append(0)
	object.append_array(size_string.to_ascii()); object.append(0)
	object.append_array(mod_string.to_ascii()); object.append(0)
	object.append_array(checksum_string.to_ascii());
	object.append_array(type_string.to_ascii())
	# Calculate header checksum
	var checksum = 0
	for i in range(0, object.size()):
		checksum += object[i]
	var checksum_string = ("%6o" % checksum).replace(" ", "0")
	var checksum_buf = checksum_string.to_ascii();
	checksum_buf.append(0);
	checksum_buf.append(32)
	# Insert header checksum
	for i in range(0, 8):
		object[148+i] = checksum_buf[i]
	# Pad header to full block size
	while (object.size() % 512) != 0: object.append(0)
	# Append file data
	object.append_array(data)
	# Pad object to full block size
	while (object.size() % 512) != 0: object.append(0)
	# Append object to output file
	output_file.store_buffer(object)

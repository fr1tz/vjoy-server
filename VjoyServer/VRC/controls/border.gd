tool
extends Panel

export(Color) var modulation = Color(1, 1, 1, 1)

func _draw():
	get_material().set_shader_param("Modulation", modulation)

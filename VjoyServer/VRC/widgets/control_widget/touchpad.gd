# Written in 2018 by Michael Goldener <mg@wasted.ch>
# To the extent possible under law, the author(s) have dedicated all copyright
# and related and neighboring rights to this software to the public domain
# worldwide. This software is distributed without any warranty.
# You should have received a copy of the CC0 Public Domain Dedication along with
# this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

extends Polygon2D

export(String, "Stick", "DPad", "Button") var mode
export(int) var radius = 64
export(int) var threshold = 0
export(Color) var fg_color = Color(1, 1, 1)

var host = null

var mTouchpadConfig = null
var mCentroid = Vector2(0, 0)
var mIndex = -1
var mWidget = {
	"center": Vector2(0, 0),
	"target": Vector2(0, 0)
}
 
func _init():
	add_user_signal("activated")
	add_user_signal("deactivated")

func _ready():
	host = get_meta("widget_host_api")
	_visibility_changed()
	connect("visibility_changed", self, "_visibility_changed")
	mCentroid = _compute_centroid()
	inic()

func _visibility_changed():
	if is_hidden():
		host.disable_canvas_input(self)
		host.disable_overlay_draw(self)
	else:
		host.enable_canvas_input(self)
		host.enable_overlay_draw(self)

func _compute_centroid():
	var centroid = Vector2(0, 0)
	var signed_area = 0.0
	var vertices = get_polygon()
	vertices.push_back(vertices[0])
	for i in range(0, vertices.size() - 1):
		var x0 = vertices[i].x
		var y0 = vertices[i].y
		var x1 = vertices[i+1].x
		var y1 = vertices[i+1].y
		var a = x0*y1 - x1*y0
		signed_area += a
		centroid.x += (x0+x1) * a
		centroid.y += (y0+y1) * a
	signed_area *= 0.5
	centroid.x /= 6.0*signed_area
	centroid.y /= 6.0*signed_area
	return centroid

func _canvas_input(event):
	var touchscreen = (event.type == InputEvent.SCREEN_TOUCH || event.type == InputEvent.SCREEN_DRAG)
	var touch = (event.type == InputEvent.SCREEN_TOUCH || event.type == InputEvent.MOUSE_BUTTON)
	var drag = (event.type == InputEvent.SCREEN_DRAG || event.type == InputEvent.MOUSE_MOTION)
	if !touch && !drag:
		return
	var index = 0
	if touchscreen:
		index = event.index
	if index == mIndex:
		if touch && !event.pressed:
			mIndex = -1
			emit_signal("deactivated")
		else:
			mWidget.target = event.pos
			var vec = mWidget.center - mWidget.target
			if vec.length() > radius:
				mWidget.center = mWidget.target + vec.normalized() * radius
	elif touch && event.pressed && has_point(event.pos):
		mIndex = index
		mWidget.center = event.pos
		mWidget.target = mWidget.center
		emit_signal("activated")
	host.update_overlay_draw()

func _overlay_draw(overlay):
	if !is_active():
		return
	overlay.draw_line(get_global_pos()+mCentroid, mWidget.center, get_color(), 4)
	overlay.draw_circle(mWidget.center, radius, fg_color)
	overlay.draw_circle(mWidget.center, radius-2, get_color())
	if mode == "DPad":
		var v = Vector2(0, radius).rotated(PI/8)
		for i in range(0, 8):
			v = v.rotated(PI/4 * i)
			overlay.draw_line(mWidget.center, mWidget.center+v, fg_color, 2)
	if threshold > 0:
		overlay.draw_circle(mWidget.center, threshold, fg_color)
		overlay.draw_circle(mWidget.center, threshold-1, get_color())
	var vec = Vector2(0, 0)
	if mode == "Stick" || mode == "DPad":
		vec = mWidget.target - mWidget.center
		if vec.length() > radius:
			vec = vec.normalized() * radius
	var p = mWidget.center+vec
	overlay.draw_line(mWidget.center, p, fg_color, 4)
	overlay.draw_circle(mWidget.center, 4, fg_color)
	overlay.draw_circle(p, 12, fg_color)

func is_active():
	return mIndex >= 0

func get_vec_angle():
	var up = Vector2(0, 1)
	var dir = (mWidget.target - mWidget.center).normalized()
	var angle = (PI + dir.angle_to(up)) / 2 / PI
	return 360 * angle

func get_vec():
	if !is_active():
		return Vector2(0, 0)
	var vec = mWidget.target - mWidget.center
	if vec.length() <= threshold:
		return Vector2(0, 0)
	if mode == "Stick":
		if vec.length() > radius:
			vec = vec.normalized() * radius
		vec = vec / radius
		return vec
	elif mode == "DPad":
		var ret 
		var angle = get_vec_angle() + 22.5
		if angle > 360:
			angle = 0
		if angle <= 45:
			ret = Vector2(0, -1)
		elif angle <= 90:
			ret = Vector2(1, -1)
		elif angle <= 135:
			ret = Vector2(1, 0)
		elif angle <= 180:
			ret = Vector2(1, 1)
		elif angle <= 225:
			ret = Vector2(0, 1)
		elif angle <= 270:
			ret = Vector2(-1, 1)
		elif angle <= 325:
			ret = Vector2(-1, 0)
		else:
			ret = Vector2(-1, -1)
		return ret

func load_touchpad_config(touchpad_config):
	mTouchpadConfig = touchpad_config
	if mTouchpadConfig.mode == "stick":
		mode = "Stick"
		radius = mTouchpadConfig.stick_config.radius
		threshold = mTouchpadConfig.stick_config.threshold
	elif mTouchpadConfig.mode == "dpad":
		mode = "DPad"
		radius = mTouchpadConfig.dpad_config.radius
		threshold = mTouchpadConfig.dpad_config.threshold
	else:
		mode = "Button"
		radius = 16
		threshold = 0

func update_joystick_state(state):
	if mTouchpadConfig.mode == "stick":
		var vec = get_vec()
		var x_action = mTouchpadConfig.stick_config.x_action
		if x_action == "axis_x":
			state.axis_x += vec.x
		elif x_action == "axis_y":
			state.axis_y += vec.x
		elif x_action == "axis_z":
			state.axis_z += vec.x
		elif x_action == "axis_x_rot":
			state.axis_x_rot += vec.x
		elif x_action == "axis_y_rot":
			state.axis_y_rot += vec.x
		elif x_action == "axis_z_rot":
			state.axis_z_rot += vec.x
		var y_action = mTouchpadConfig.stick_config.y_action
		if y_action == "axis_x":
			state.axis_x += vec.y
		elif y_action == "axis_y":
			state.axis_y += vec.y
		elif y_action == "axis_z":
			state.axis_z += vec.y
		elif y_action == "axis_x_rot":
			state.axis_x_rot += vec.y
		elif y_action == "axis_y_rot":
			state.axis_y_rot += vec.y
		elif y_action == "axis_z_rot":
			state.axis_z_rot += vec.y
	elif mTouchpadConfig.mode == "dpad":
		var vec = get_vec()
		state.axis_x += vec.x
		state.axis_y += vec.y
	elif mTouchpadConfig.mode == "button":
		if is_active():
			var button_num = mTouchpadConfig.button_config.button_num
			state.buttons[button_num-1] += 1

#-------------------------------------------------------------------------------
# Code below was copied from a post by user "lukas" (https://godotengine.org/qa/user/lukas)
# https://godotengine.org/qa/3160/how-test-whether-point-lies-inside-sprite-collisionobject2d

var poly_corners  =  0 # how many corners the polygon has (no repeats)
var poly_x = [] # horizontal coordinates of corners
var poly_y = [] # vertical coordinates of corners
var constant = [] # storage for precalculated constants (same size as poly_x)
var multiple = [] # storage for precalculated multipliers (same size as poly_x)
var vertices_pos = [] # storage for global coordinates of polygon's vertices

func inic():
	var poly_pos = get_global_pos() # global position of polygon
	var vertices = get_polygon() # local coordiantes of vertices
	poly_corners = vertices.size()
	poly_x.resize(poly_corners)
	poly_y.resize(poly_corners)
	constant.resize(poly_corners)
	multiple.resize(poly_corners)
	vertices_pos.resize(poly_corners)
	for i in range(poly_corners): 
		vertices_pos[i] = poly_pos + vertices[i]
		poly_x[i] = vertices_pos[i].x
		poly_y[i] = vertices_pos[i].y
	precalc_values_has_point(poly_x, poly_y)

func precalc_values_has_point(poly_x, poly_y): # precalculation of constant and multiple
	var j = poly_corners - 1
	for i in range(poly_corners): 
		if poly_y[j] == poly_x[i]:
			constant[i] = poly_y[i]
			multiple[i] = 0.0
		else:
			constant[i] = poly_x[i] - poly_y[i] * poly_x[j] / (poly_y[j] - poly_y[i]) + poly_y[i] * poly_x[i] / (poly_y[j] - poly_y[i])
			multiple[i] = (poly_x[j] - poly_x[i]) / (poly_y[j] - poly_y[i])
		j = i

func has_point(point):
	var x = point.x
	var y = point.y
	var j = poly_corners - 1
	var odd_nodes = 0
	for i in range(poly_corners): 
		if (poly_y[i] < y and poly_y[j] >= y) or (poly_y[j] < y and poly_y[i] >= y):
			if y * multiple[i] + constant[i] < x:
				odd_nodes += 1
		j = i
	if odd_nodes % 2 == 0:
		return false
	else:
		return true

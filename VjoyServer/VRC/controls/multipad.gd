# Written in 2018 by Michael Goldener <mg@wasted.ch>
# To the extent possible under law, the author(s) have dedicated all copyright
# and related and neighboring rights to this software to the public domain
# worldwide. This software is distributed without any warranty.
# You should have received a copy of the CC0 Public Domain Dedication along with
# this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

extends Polygon2D

export(String, "Stick", "DPad", "SingleButton", "DualButton") var mode
export(int) var radius = 64
export(int) var threshold = 0
export(NodePath) var canvas
export(Color) var fg_color = Color(1, 1, 1)

var host = null

var mCanvas = null
var mCentroid = Vector2(0, 0)
var mIndex = -1
var mPaddingPolygon = null
var mWidget = {
	"center": Vector2(0, 0),
	"target": Vector2(0, 0)
}
 
func _init():
	add_user_signal("activated")
	add_user_signal("deactivated")

func _ready():
	mCanvas = get_node(canvas)
	mCanvas.add_painter(self)
	mCentroid = _compute_centroid()
	var polygon_util = get_node("/root/vrc/polygon_util")
	mPaddingPolygon = polygon_util.shrink_polygon(get_polygon(), 10)
	inic()

func _vrc_init(vrc_host_api):
	host = vrc_host_api
	host.enable_canvas_input(self)

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
		mCanvas.update()
	elif touch && event.pressed && has_point(event.pos):
		mIndex = index
		mWidget.center = event.pos
		mWidget.target = mWidget.center
		emit_signal("activated")
		mCanvas.update()

func _draw():
	VisualServer.canvas_item_set_clip(get_canvas_item(), true)
	draw_colored_polygon(mPaddingPolygon, Color(0, 0, 0, 0.5))
	var vertices = get_polygon() 
	for i in range(0, vertices.size()):
		var p1 = vertices[i]
		draw_line(p1, mCentroid, get_color(), 3)
		if i == vertices.size()-1:
			i = -1
		var p2 = vertices[i+1]
		#draw_line(p1, p2, Color(1,1,1,1), 3)
	draw_circle(mCentroid, 3, get_color())

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

func draw_on_canvas(canvas):
	if !is_active():
		return
	mCanvas.draw_set_transform(-mCanvas.get_global_pos(), 0, Vector2(1,1))
	#draw_circle5(mWidget.center, radius, 0, 360, color, 4)
	mCanvas.draw_line(get_global_pos()+mCentroid, mWidget.center, get_color(), 4)
	mCanvas.draw_circle(mWidget.center, radius, fg_color)
	mCanvas.draw_circle(mWidget.center, radius-2, Color(0.5,0.5,0.5,1))
	if mode == "DPad":
		var v = Vector2(0, radius).rotated(PI/8)
		for i in range(0, 8):
			v = v.rotated(PI/4 * i)
			mCanvas.draw_line(mWidget.center, mWidget.center+v, fg_color, 2)
	if threshold > 0:
		var r = radius * threshold
		mCanvas.draw_circle(mWidget.center, r, fg_color)
		mCanvas.draw_circle(mWidget.center, r-2, Color(0.5,0.5,0.5,1))
	var vec = Vector2(0, 0)
	if mode == "Stick" || mode == "DPad":
		vec = mWidget.target - mWidget.center
		if vec.length() > radius:
			vec = vec.normalized() * radius
	var p = mWidget.center+vec
	mCanvas.draw_line(mWidget.center, p, fg_color, 4)
	mCanvas.draw_circle(mWidget.center, 4, fg_color)
	mCanvas.draw_circle(p, 12, fg_color)

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

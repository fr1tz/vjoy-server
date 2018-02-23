# Written in 2018 by Michael Goldener <mg@wasted.ch>
# To the extent possible under law, the author(s) have dedicated all copyright
# and related and neighboring rights to this software to the public domain
# worldwide. This software is distributed without any warranty.
# You should have received a copy of the CC0 Public Domain Dedication along with
# this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

extends Polygon2D

export(String, "Stick", "SingleButton", "DualButton") var mode
export(NodePath) var canvas
export(Color) var fg_color = Color(1, 1, 1)

const radius = 64

var host = null

var mCanvas = null
var mIndex = -1
var mCenter = Vector2(0, 0)
var mTarget = Vector2(0, 0)

func _ready():
	mCanvas = get_node(canvas)
	inic()

func _vrc_init(vrc_host_api):
	host = vrc_host_api
	host.enable_canvas_input(self)

func _canvas_input(event):
	var touchscreen = (event.type == InputEvent.SCREEN_TOUCH || event.type == InputEvent.SCREEN_DRAG)
	var touch = (event.type == InputEvent.SCREEN_TOUCH || event.type == InputEvent.MOUSE_BUTTON)
	var drag = (event.type == InputEvent.SCREEN_DRAG || event.type == InputEvent.MOUSE_MOTION)
	if !touch && !drag:
		return
	var index = 0
	if touchscreen:
		index = event.index
	var move = {
		type = 0,
		vec = null
	}
	if index == mIndex:
		if touch && !event.pressed:
			mIndex = -1
			move.type = 2
			move.vec = null
		else:
			mTarget = event.pos - get_global_pos()
			move.type = 1
		update()
	elif touch && event.pressed && has_point(event.pos):
		mIndex = index
		mCenter = event.pos - get_global_pos()
		mTarget = mCenter
		move.type = 1
		update()

func _draw():
#	print("yay")
#	for shape_idx in range(0, get_shape_count()):
#		var shape = get_shape(shape_idx)
#		print(shape.get_type())
#		if shape.get_type() == "ConvexPolygonShape2D":
#			print(shape.get_points())
#			draw_colored_polygon(shape.get_points(), Color(0,0,0))
	if mIndex < 0:
		return
	var vec = get_vec()
	var p = mCenter+vec
	print(p)
	#draw_set_transform(get_pos() - get_pos(), 0, Vector2(1,1))
	#draw_circle5(mCenter, radius, 0, 360, color, 4)
	draw_line(mCenter, p, fg_color, 8)
	draw_circle(mCenter, 10, fg_color)
	draw_circle(p, 20, fg_color)

func is_active():
	return mIndex >= 0

func get_angle():
	var up = Vector2(-1, 0)
	var dir = (mTarget - mCenter).normalized()
	var angle = (PI + dir.angle_to(up)) / 2 / PI
	return 360 * angle

func get_vec():
	if !is_active():
		return Vector2(0, 0)
	var vec = mTarget-mCenter
	if vec.length() > radius:
		vec = vec.normalized() * radius
	return vec

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

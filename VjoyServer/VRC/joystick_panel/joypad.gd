extends ReferenceFrame

const radius = 64

export(Color) var color = Color(1, 1, 1)

var mIndex = -1
var mCenter = Vector2(0, 0)
var mTarget = Vector2(0, 0)

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
	elif touch && event.pressed && get_global_rect().has_point(event.pos):
		mIndex = index
		mCenter = event.pos - get_global_pos()
		mTarget = mCenter
		move.type = 1

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

func draw_on_canvas(canvas):
	if mIndex < 0:
		return
	var vec = get_vec()
	var p = mCenter+vec
	canvas.draw_set_transform(get_pos() - canvas.get_pos(), 0, Vector2(1,1))
	canvas.draw_circle5(mCenter, radius, 0, 360, color, 4)
	canvas.draw_line(mCenter, p, color, 8)
	canvas.draw_circle(mCenter, 10, color)
	canvas.draw_circle(p, 20, color)

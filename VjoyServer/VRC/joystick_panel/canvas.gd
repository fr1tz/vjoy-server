# Written in 2018 by Michael Goldener <mg@wasted.ch>
# To the extent possible under law, the author(s) have dedicated all copyright
# and related and neighboring rights to this software to the public domain
# worldwide. This software is distributed without any warranty.
# You should have received a copy of the CC0 Public Domain Dedication along with
# this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

extends ReferenceFrame

var mPainters = []

func _draw():
	VisualServer.canvas_item_set_clip(get_canvas_item(), true)
	for painter in mPainters:
		painter.draw_on_canvas(self)

func add_painter(painter):
	if mPainters.has(painter):
		return
	mPainters.append(painter)

func remove_painter(painter):
	mPainters.erase(painter)

func draw_circle5(center, radius, angleFrom, angleTo, color, line_width = 4):
	var nbPoints = 32
	var pointsArc = Vector2Array() 
	for i in range(nbPoints+1):
		var anglePoint = angleFrom + i*(angleTo-angleFrom)/nbPoints - 90
		var point = center + Vector2( cos(deg2rad(anglePoint)), sin(deg2rad(anglePoint)) )* radius
		pointsArc.push_back( point )
	for indexPoint in range(nbPoints):
		#printt(indexPoint, pointsArc[indexPoint], pointsArc[indexPoint+1])
		draw_line(pointsArc[indexPoint], pointsArc[indexPoint+1], color, line_width)

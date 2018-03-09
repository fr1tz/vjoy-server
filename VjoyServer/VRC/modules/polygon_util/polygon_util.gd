extends Node

# based on http://local.wasp.uwa.edu.au/~pbourke/geometry/lineline2d/, edgeA => "line a", edgeB => "line b"
func _edges_intersection(edgeA, edgeB):
	var den = (edgeB.vertex2.y - edgeB.vertex1.y) * (edgeA.vertex2.x - edgeA.vertex1.x) - (edgeB.vertex2.x - edgeB.vertex1.x) * (edgeA.vertex2.y - edgeA.vertex1.y)
	if den == 0:
		return null  # lines are parallel or conincident
	var ua = ((edgeB.vertex2.x - edgeB.vertex1.x) \
		 * (edgeA.vertex1.y - edgeB.vertex1.y) \
		 - (edgeB.vertex2.y - edgeB.vertex1.y) \
		 * (edgeA.vertex1.x - edgeB.vertex1.x)) \
		 / den
	var ub = ((edgeA.vertex2.x - edgeA.vertex1.x) \
		* (edgeA.vertex1.y - edgeB.vertex1.y) \
		- (edgeA.vertex2.y - edgeA.vertex1.y) \
		* (edgeA.vertex1.x - edgeB.vertex1.x)) \
		/ den
	prints(ua, ub)
	if ua < 0 || ub < 0 || ua > 1 || ub > 1:
		return null
	var x = edgeA.vertex1.x + ua * (edgeA.vertex2.x - edgeA.vertex1.x)
	var y = edgeA.vertex1.y + ua * (edgeA.vertex2.y - edgeA.vertex1.y)
	return Vector2(x, y)

func _append_arc(vertices, center, radius, startVertex, endVertex, isPaddingBoundary):
	var twoPI = PI * 2
	var startAngle = atan2(startVertex.y - center.y, startVertex.x - center.x)
	var endAngle = atan2(endVertex.y - center.y, endVertex.x - center.x)
	if startAngle < 0:
		startAngle += twoPI
	if endAngle < 0:
		endAngle += twoPI
	var arcSegmentCount = 5; # An odd number so that one arc vertex will be eactly arcRadius from center.
	var angle
	if startAngle > endAngle:
		angle = startAngle - endAngle
	else:
		angle = startAngle + twoPI - endAngle
	var angle5
	if isPaddingBoundary:
		angle5 = -angle
	else:
		angle5 = (twoPI - angle) / arcSegmentCount
	vertices.push_back(startVertex)
	for i in range(1, arcSegmentCount):
		var angle = startAngle + angle5 * i
		var x = center.x + cos(angle) * radius
		var y = center.y + sin(angle) * radius 
		var vertex = Vector2(x, y)
		vertices.push_back(vertex);
	vertices.push_back(endVertex);

func _create_offset_edge(edge, dx, dy):
	var offset_edge = {
		"vertex1": Vector2(edge.vertex1.x + dx, edge.vertex1.y + dy),
		"vertex2": Vector2(edge.vertex2.x + dx, edge.vertex2.y + dy)
	}
	return offset_edge

func _inward_edge_normal(edge):
	# Assuming that polygon vertices are in clockwise order
	var dx = edge.vertex2.x - edge.vertex1.x
	var dy = edge.vertex2.y - edge.vertex1.y
	var edgeLength = sqrt(dx*dx + dy*dy)
	return Vector2(-dy/edgeLength, dx/edgeLength)

func _outward_edge_normal(edge):
	var n = _inward_edge_normal(edge);
	return Vector2(-n.x, -n.y)

func _left_side(vertex1, vertex2, p):
	return ((p.x - vertex1.x) * (vertex2.y - vertex1.y)) - ((vertex2.x - vertex1.x) * (p.y - vertex1.y))

func _is_reflex_vertex(polygon, vertex_index):
	# Assuming that polygon vertices are in clockwise order
	var thisVertex = polygon.vertices[vertex_index];
	var nextVertex = polygon.vertices[(vertex_index + 1) % polygon.vertices.size()];
	var prevVertex = polygon.vertices[(vertex_index + polygon.vertices.size() - 1) % polygon.vertices.size()];
	if _left_side(prevVertex, nextVertex, thisVertex) < 0:
		return true  # TBD: return true if thisVertex is inside polygon when thisVertex isn't included
	return false

func _create_padding_polygon(polygon, shapePadding):
	var offsetEdges = [];
	for i in range(0, polygon.edges.size()):
		var edge = polygon.edges[i]
		var dx = edge.inwardNormal.x * shapePadding
		var dy = edge.inwardNormal.y * shapePadding
		offsetEdges.push_back(_create_offset_edge(edge, dx, dy))
	var vertices = [];
	for i in range(0, offsetEdges.size()):
		var thisEdge = offsetEdges[i]
		var prevEdge = offsetEdges[(i + offsetEdges.size() - 1) % offsetEdges.size()]
		var vertex = _edges_intersection(prevEdge, thisEdge)
		if vertex != null:
			vertices.push_back(vertex);
		else:
			var arcCenter = polygon.edges[i].vertex1;
			_append_arc(vertices, arcCenter, shapePadding, prevEdge.vertex2, thisEdge.vertex1, true);
	var paddingPolygon = _create_polygon(vertices)
	paddingPolygon.offsetEdges = offsetEdges
	return paddingPolygon

func _create_polygon(vertices):
	var polygon = {
		"vertices": vertices,
		"vertice_is_reflex": [],
		"edges": [],
		"minX": vertices[0].x,
		"minY": vertices[0].y,
		"maxX": 0,
		"maxY": 0,
		"closed": true
	}
	polygon.vertice_is_reflex.resize(vertices.size())
	for i in range(0, vertices.size()):
		polygon.vertice_is_reflex[i] = _is_reflex_vertex(polygon, i)
		var edge = {
			"vertex1": vertices[i], 
			"vertex2": vertices[(i + 1) % vertices.size()], 
			"outwardNormal": null,
			"inwardNormal": null,
			"polygon": polygon, 
			"index": i
		};
		edge.outwardNormal = _outward_edge_normal(edge)
		edge.inwardNormal = _inward_edge_normal(edge)
		polygon.edges.push_back(edge)
		var x = vertices[i].x
		var y = vertices[i].y
		polygon.minX = min(x, polygon.minX)
		polygon.minY = min(y, polygon.minY)
		polygon.maxX = max(x, polygon.maxX)
		polygon.maxY = max(y, polygon.maxY)
	return polygon

func shrink_polygon(vertices, padding):
	var polygon = _create_polygon(vertices)
	var padding_polygon = _create_padding_polygon(polygon, padding)
	return padding_polygon.vertices

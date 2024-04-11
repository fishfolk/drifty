extends EditorNode3DGizmoPlugin


const HANDLES_PER_POINT := 3
const POSITION_HANDLES_LENGTH := 3.0

# [X, Y, Z]
var position_lines := [PackedVector3Array(), PackedVector3Array(), PackedVector3Array()]
var position_handles := PackedVector3Array()

func _init():
  create_material("main", Color(1,0,0))
  create_material("red", Color(1,0,0))
  create_material("green", Color(0,1,0))
  create_material("blue", Color(0,0,1))
  create_handle_material("handles")

func _get_gizmo_name():
  return "Path3DGizmos"

func _has_gizmo(node):
  return node is Path3D

func _redraw(gizmo: EditorNode3DGizmo):
  gizmo.clear()

  var node3d = gizmo.get_node_3d()
  var path3d := node3d as Path3D

  var curve := path3d.curve

  for line_group in position_lines:
    line_group.clear()

  position_handles.clear()

  for point_index in range(curve.point_count):
    draw_point_gizmo(gizmo, curve, point_index)

  gizmo.add_lines(position_lines[0], get_material("red", gizmo), false)
  gizmo.add_lines(position_lines[1], get_material("green", gizmo), false)
  gizmo.add_lines(position_lines[2], get_material("blue", gizmo), false)

  gizmo.add_handles(position_handles, get_material("handles", gizmo), [])

func draw_point_gizmo(gizmo, curve: Curve3D, point_index: int):
  var position := curve.get_point_position(point_index)
  var tilt := curve.get_point_tilt(point_index)
  var point_in := curve.get_point_in(point_index)
  var point_out := curve.get_point_out(point_index)

  var pos_id := 0

  for dir in [Vector3.RIGHT, Vector3.UP, Vector3.BACK]:
    position_lines[pos_id].push_back(position)
    position_lines[pos_id].push_back(position + dir * POSITION_HANDLES_LENGTH)

    position_handles.push_back(position + dir * POSITION_HANDLES_LENGTH)
    
    pos_id += 1

func _set_handle(gizmo, handle_id: int, secondary: bool, camera: Camera3D, screen_pos: Vector2):
  var curve := get_curve(gizmo)
  var point_index := get_point_index(handle_id)
  var position := curve.get_point_position(point_index)
  var ray_origin : Vector3 = camera.project_ray_origin(screen_pos)
  var ray_normal : Vector3 = camera.project_ray_normal(screen_pos)

  # There's definitely a way to express this in a less repetitive manner
  # but tbh I honestly can't be bothered to work it out. Something about
  # doing component-wise vector multiplication w/ unit vectors probably.
  if handle_id % HANDLES_PER_POINT == 0:
    var distance := 0.0
    if abs(ray_normal.z) > abs(ray_normal.y):
      distance = (position.z - ray_origin.z) / ray_normal.z
    else:
      distance = (position.y - ray_origin.y) / ray_normal.y

    var projected := ray_origin + ray_normal * distance
    var new_x = projected.x - POSITION_HANDLES_LENGTH

    curve.set_point_position(
      point_index,
      Vector3(
        new_x,
        position.y,
        position.z
      )
    )
  elif handle_id % HANDLES_PER_POINT == 1:
    var distance := 0.0
    if abs(ray_normal.z) > abs(ray_normal.x):
      distance = (position.z - ray_origin.z) / ray_normal.z
    else:
      distance = (position.x - ray_origin.x) / ray_normal.x

    var projected := ray_origin + ray_normal * distance
    var new_y = projected.y - POSITION_HANDLES_LENGTH

    curve.set_point_position(
      point_index,
      Vector3(
        position.x,
        new_y,
        position.z
      )
    )
  elif handle_id % HANDLES_PER_POINT == 2:
    var distance := 0.0
    if abs(ray_normal.x) > abs(ray_normal.y):
      distance = (position.x - ray_origin.x) / ray_normal.x
    else:
      distance = (position.y - ray_origin.y) / ray_normal.y

    var projected := ray_origin + ray_normal * distance
    var new_z = projected.z - POSITION_HANDLES_LENGTH

    curve.set_point_position(
      point_index,
      Vector3(
        position.x,
        position.y,
        new_z
      )
    )

func _commit_handle(gizmo, handle_id: int, secondary: bool, restore, cancel: bool):
  pass

func _get_handle_name(gizmo, handle_id: int, secondary: bool) -> String:
  if handle_id % HANDLES_PER_POINT == 0:
    return "Point X"
  elif handle_id % HANDLES_PER_POINT == 1:
    return "Point Y"
  elif handle_id % HANDLES_PER_POINT == 2:
    return "Point Z"
  
  return "<UNKNOWN>"

func _get_handle_value(gizmo, handle_id: int, secondary: bool):
  var curve := get_curve(gizmo)

  if handle_id % HANDLES_PER_POINT == 0:
    return get_position(curve, handle_id).x
  elif handle_id % HANDLES_PER_POINT == 1:
    return get_position(curve, handle_id).y
  elif handle_id % HANDLES_PER_POINT == 2:
    return get_position(curve, handle_id).z

  return 0

# Helpers
func get_curve(gizmo: EditorNode3DGizmo) -> Curve3D:
  var node3d = gizmo.get_node_3d()
  var path3d := node3d as Path3D
  return path3d.curve

func get_point_index(handle_id: int) -> int:
  return handle_id / HANDLES_PER_POINT

# in/out/position/tilt getters
# func get_in(curve: Curve3D, gizmo_id: int) -> Vector3:
#   return curve.get_point_in(get_point_index(gizmo_id))

# func get_out(curve: Curve3D, gizmo_id: int) -> Vector3:
#   return curve.get_point_out(get_point_index(gizmo_id))

func get_position(curve: Curve3D, gizmo_id: int) -> Vector3:
  return curve.get_point_position(get_point_index(gizmo_id))

# func get_tilt(curve: Curve3D, gizmo_id: int) -> float:
#   return curve.get_point_tilt(get_point_index(gizmo_id))
tool
extends Spatial

onready var mirror_camera = $Viewport/Camera
var active_camera = null

func _ready():
	print("[DEBUG] Setting up mirror...")
	var viewport
	if Engine.editor_hint:
		viewport = find_viewport_3d(get_node("/root/EditorNode"), 0)
		$Viewport.size = viewport.size
		active_camera = viewport.get_child(0)


func _process(_delta):
	# Make sure we're only updating position if there's a camera active
	if active_camera:
		var plane_normal = -self.get_global_transform().basis.z.normalized()
		var camera_facing = -active_camera.get_global_transform().basis.z
		mirror_camera.translation = reflect_point_3d(self.translation, plane_normal, active_camera.translation)

		# This part don't work yet for all angles lol
		var new_rotation = active_camera.rotation
		new_rotation.y = -new_rotation.y
		new_rotation.z = -new_rotation.z
		mirror_camera.rotation = new_rotation
		
	elif get_tree().get_root().get_node("Spatial").client and ARVRServer.primary_interface:
		$Viewport.size = ARVRServer.primary_interface.get_render_targetsize()
		active_camera = get_tree().get_root().get_node("Spatial").client.get_node("ARVROrigin").get_node("Player_Camera")
		
		#mirror_camera.fov = $Viewport.size.

func reflect_point_3d(plane_point, plane_normal, source_point):
	var to_plane = plane_point - source_point
	var to_closest_point = plane_normal * (to_plane.dot(plane_normal)) # Assuming plane_normal is normalized
	return source_point + 2*to_closest_point

func raycast_plane(plane_point, plane_normal, line_point, line_dir):
	pass

# Ripped from https://github.com/godotengine/godot-proposals/issues/1302#issuecomment-753432717
func find_viewport_3d(node: Node, recursive_level):
	if node.get_class() == "SpatialEditor":
		return node.get_child(1).get_child(0).get_child(0).get_child(0).get_child(0).get_child(0)
	else:
		recursive_level += 1
		if recursive_level > 15:
			return null
		for child in node.get_children():
			var result = find_viewport_3d(child, recursive_level)
			if result != null:
				return result

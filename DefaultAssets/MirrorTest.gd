tool
extends Spatial

onready var plane_mark = get_node("PlaneTransform")

onready var mirror_cam = $Viewport/Camera
var main_cam = null

func _ready():
	
	print("[DEBUG] Setting up mirror...")
	var viewport
	if Engine.editor_hint:
		viewport = find_viewport_3d(get_node("/root/EditorNode"), 0)
		$Viewport.size = viewport.size
		main_cam = viewport.get_child(0)
	elif ARVRServer.get_primary_interface():
		$Viewport.size = ARVRServer.get_primary_interface().get_render_targetsize()
		main_cam = get_viewport().get_camera()
	else:
		viewport = get_viewport()
		$Viewport.size = viewport.size
		main_cam = viewport.get_camera()
	
	
func _process(delta):
	
	if not main_cam:
		return
		
	# Compute reflection plane and its global transform  (origin in the middle, 
	#  X and Y axis properly aligned with the viewport, -Z is the mirror's forward direction) 
	var plane_origin = plane_mark.global_transform.origin
	var plane_normal = plane_mark.global_transform.basis.z.normalized()
	var reflection_plane = Plane(plane_normal, plane_origin.dot(plane_normal))
	var reflection_transform = plane_mark.global_transform
	
	# Main camera position
	var cam_pos = main_cam.global_transform.origin 
	
	# The projected point of main camera's position onto the reflection plane
	var proj_pos = reflection_plane.project(cam_pos)
	
	# Main camera position reflected over the mirror's plane
	var mirrored_pos = cam_pos + (proj_pos - cam_pos) * 2.0
	
	# Compute mirror camera transform
	# - origin at the mirrored position
	# - looking perpedicularly into the relfection plane (this way the near clip plane will be 
	#      parallel to the reflection plane) 
	var t = Transform(Basis(), mirrored_pos)
	t = t.looking_at(proj_pos, reflection_transform.basis.y.normalized())
	mirror_cam.set_global_transform(t)
	
	# Compute the tilting offset for the frustum (the X and Y coordinates of the mirrored camera position
	#	when expressed in the reflection plane coordinate system) 
	var offset = reflection_transform.xform_inv(cam_pos)
	offset = Vector2(offset.x, offset.y)
	
	# Set mirror camera frustum
	# - size 	-> mirror's width (camera is set to KEEP_WIDTH)
	# - offset 	-> previously computed tilting offset
	# - z_near 	-> distance between the mirror camera and the reflection plane (this ensures we won't
	#               be reflecting anything behind the mirror)
	# - z_far	-> large arbitrary value (render distance limit form th mirror camera position)
	mirror_cam.set_frustum(self.scale.z, -offset, proj_pos.distance_to(cam_pos), 1000.0)

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

tool
extends Spatial

onready var mirror_camera = $Viewport/Camera
var active_camera = null

func _ready():
	var viewport
	if Engine.editor_hint:
		print("[DEBUG] Setting up editor mirror...")
		viewport = find_viewport_3d(get_node("/root/EditorNode"), 0)
		$Viewport.size = viewport.size
		active_camera = viewport.get_child(0)
		
	VisualServer.connect("frame_pre_draw", self, "update_camera_pos")

#func _process(_delta):
#	update_camera_pos()

func update_camera_pos():
	# Make sure we're only updating position if there's a camera active
	if active_camera:
		self.scale.z *= -1
		$CameraTracker.global_transform = active_camera.get_global_transform()
		self.scale.z *= -1
		mirror_camera.global_transform = $CameraTracker.global_transform
		mirror_camera.global_transform.basis.x *= -1
		
	elif get_tree().get_root().get_node("Spatial").get_node("Peer").get_node("You") and ARVRServer.primary_interface:
		print("[DEBUG] Setting up VR mirror...")
		$Viewport.size = ARVRServer.primary_interface.get_render_targetsize()
		# $Viewport.arvr = true
		$MirrorSurface.get_surface_material(0).set_shader_param("is_arvr", true)
		active_camera = get_tree().get_root().get_node("Spatial").get_node("Peer").head
		
		mirror_camera.fov = 104 # Testing with quest


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

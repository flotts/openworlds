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
		# THIS TRANSFORM DOES NOT WORK AT ALL ANGLES
		var new_translation = active_camera.translation
		new_translation.x = 2*self.translation.x - new_translation.x
		mirror_camera.translation = new_translation

		var new_rotation = active_camera.rotation
		new_rotation.y = -new_rotation.y
		mirror_camera.rotation = new_rotation
		
	elif get_tree().get_root().get_node("Spatial").client:
		active_camera = get_tree().get_root().get_node("Spatial").client.get_node("ARVROrigin").get_node("Player_Camera")
		


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

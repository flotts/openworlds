extends Node

onready var VRM_LOADER = preload("res://addons/vrm/vrm_loader.gd").new()
onready var peer = get_node("../..")

var current_avatar: Spatial
var loader_thread = Thread.new()


## AVATAR LOADING

# Start a thread to load the avatar
func begin_load_avatar(path):
	if loader_thread.is_alive():
		print("[INFO] Already loading avatar, wait a second")
		return # Maybe just yield until is_loading_avatar?
	
	print("[INFO] Loading avatar from " + path + " ...")
	
	loader_thread = Thread.new()
	loader_thread.start(self, "load_avatar_async", path, 0)

func load_avatar_async(path):
	var new_avatar = VRM_LOADER.import_scene(path, 1, 1000)
	
	call_deferred("finish_loading_avatar", new_avatar)

# Back on main thread, since it's bad to change the scene off thread?
func finish_loading_avatar(new_avatar):
	if current_avatar:
		current_avatar.queue_free()
	
	current_avatar = new_avatar
	add_child(current_avatar)
	
	# Rescale player to fit avatar
	var skel = current_avatar.find_node("Skeleton") #Not sure where the viewpoint is?
	var head_idx = find_head_bone(skel)
	var head_height = skel.get_bone_global_pose(head_idx).origin.y
	ARVRServer.world_scale = head_height / peer.user_height
	
	print("[INFO] Avatar loaded.")


## UTILITY

func find_head_bone(skel):
	var head_idx = skel.find_bone("head")
	if head_idx == -1:
		head_idx = skel.find_bone("Head")
	if head_idx == -1:
		head_idx = skel.find_bone("head_Armature")
	return head_idx

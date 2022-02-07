extends Spatial

export var user_height = 1.8

onready var main = get_tree().get_root().get_node("Spatial")
var current_avatar

onready var head = $Player_Camera
var lhand
var rhand
var trackers

func _ready():
	
	# Initialize VR Engine
	var VR = ARVRServer.find_interface("OpenVR")
	if not (VR and VR.initialize()):
		return
		
	get_viewport().arvr = true

	OS.vsync_enabled = false
	Engine.target_fps = 90
	
	# Start with default avatar
	load_avatar("res://DefaultAssets/Godette/Godette_vrm_v4.vrm")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	# Track model, IK etc
	if current_avatar:
		var skel = current_avatar.find_node("Skeleton")
	
	# Submit data over network (how often? which thread?)
	if get_tree().get_network_peer():
		if get_tree().get_network_peer().get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED:
			_send_tracker_pos()

func _send_tracker_pos():
	var head_pos = null
	var lhand_pos = null
	var rhand_pos = null
	var tracker_arr = []
	
	if head:
		head_pos = head.transform
	if lhand:
		lhand_pos = lhand.transform
	if rhand:
		rhand_pos = rhand.transform
	
	
	main.rpc_unreliable("update_remote_tracker_pos", head_pos, lhand_pos, rhand_pos, tracker_arr)

func load_avatar(path):
	print("Loading avatar...")
	
	if current_avatar:
		remove_child(current_avatar)
	current_avatar = load(path).instance()
	add_child(current_avatar)
	
	# Rescale player to fit avatar
	var skel = current_avatar.find_node("Skeleton")
	var head_idx = skel.find_bone("head_Armature")
	var head_height = skel.get_bone_global_pose(head_idx).origin.y
	ARVRServer.world_scale = head_height/user_height


func _on_SteamVRController_controller_activated(controller: ARVRController):
	match controller.get_hand():
		ARVRPositionalTracker.TRACKER_LEFT_HAND:
			lhand = controller
		ARVRPositionalTracker.TRACKER_RIGHT_HAND:
			rhand = controller
		ARVRPositionalTracker.TRACKER_HAND_UNKNOWN:
			trackers.append(controller)
	
	if get_tree().get_network_peer():
		if get_tree().get_network_peer().get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED:
			main.rpc("remote_tracker_activated", controller.controller_id())


func _on_SteamVRController_controller_deactivated(controller):
	match controller.get_hand():
		ARVRPositionalTracker.TRACKER_LEFT_HAND:
			lhand = null
		ARVRPositionalTracker.TRACKER_RIGHT_HAND:
			rhand = null
		ARVRPositionalTracker.TRACKER_HAND_UNKNOWN:
			trackers.erase(controller)
			
	if get_tree().get_network_peer():
		if get_tree().get_network_peer().get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED:
			main.rpc("remote_tracker_deactivated", controller.controller_id())

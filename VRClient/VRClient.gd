extends Spatial

onready var main = get_tree().get_root().get_node("Spatial")
onready var vr_origin = get_node("ARVROrigin")


func _ready():
	
	# Initialize VR Engine
	var VR = ARVRServer.find_interface("OpenVR")
	if not (VR and VR.initialize()):
		return
		
	get_viewport().arvr = true

	OS.vsync_enabled = false
	Engine.target_fps = 90


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	# Submit data over network (how often? which thread?)
	if get_tree().get_network_peer():
		if get_tree().get_network_peer().get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED:
			_send_tracker_pos()

func _send_tracker_pos():
	var head_pos
	var lhand_pos
	var rhand_pos
	var tracker_arr = []
	for tracker in vr_origin.get_children():
		if tracker is ARVRCamera:
			head_pos = tracker.transform
		elif tracker is ARVRController:
			match tracker.get_hand():
				ARVRPositionalTracker.TRACKER_LEFT_HAND:
					lhand_pos = tracker.transform
				ARVRPositionalTracker.TRACKER_RIGHT_HAND:
					rhand_pos = tracker.transform
				ARVRPositionalTracker.TRACKER_HAND_UNKNOWN:
					tracker_arr.append(tracker.transform)
			
	main.rpc_unreliable("update_remote_tracker_pos", head_pos, lhand_pos, rhand_pos, tracker_arr)


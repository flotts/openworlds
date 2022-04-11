extends Client
class_name OVRClient

onready var head = $You/PlayerCamera
var lhand
var rhand
var trackers = []

export var user_height = 1.8


func _ready():
	
	# Initialize VR Engine
	var VR = ARVRServer.find_interface("OpenVR")
	if not (VR and VR.initialize()):
		return
		
	get_viewport().arvr = true

	OS.vsync_enabled = false
	Engine.target_fps = 90


## SEND AVATAR UPDATES

func _process(_delta):
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
	
	rpc_unreliable("update_remote_tracker_pos", head_pos, lhand_pos, rhand_pos, tracker_arr)



## SIGNALS

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
			rpc("remote_tracker_activated", controller.controller_id)

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
			rpc("remote_tracker_deactivated", controller.controller_id)


extends Client
class_name DesktopClient

onready var head = $Player_Camera


## SEND AVATAR UPDATES

func _process(_delta):
	# Submit data over network (how often? which thread?)
	if get_tree().get_network_peer():
		if get_tree().get_network_peer().get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED:
			_send_pos()

func _send_pos():
	var head_pos = null
	
	if head:
		head_pos = head.transform
		
	rpc_unreliable("update_remote_tracker_pos", head_pos, null, null, null)

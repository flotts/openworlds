extends "res://Client.gd"

onready var head = $You/Player_Camera
var lhand
var rhand
var trackers
var is_loading_avatar = false


func _ready():
	
	# Initialize VR Engine
	var VR = ARVRServer.find_interface("OpenVR")
	if not (VR and VR.initialize()):
		return
		
	get_viewport().arvr = true

	OS.vsync_enabled = false
	Engine.target_fps = 90
	
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")


# Send avatar updates

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

func _connected_ok():
	var id = get_tree().get_network_unique_id()
	#client.set_network_master( id )
	print("[INFO] Connected to server.")

func _server_disconnected():
	get_tree().set_network_peer(null)
	print("[INFO] Server disconnected.")

func _connected_fail():
	get_tree().set_network_peer(null) # Remove peer
	print("[INFO] Failed to connect to server.")


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


func _on_VoiceOrchestrator_created_instance():
	print("[DEBUG] Created VoiceInstance for remote player")

func _on_VoiceOrchestrator_removed_instance():
	print("[DEBUG] Removed VoiceInstance for remote player")


## GUI CALLS

# Called from the load world GUI (on a client)
func on_change_world(url):
	rpc_id(1, "request_change_world", url)
	
# Called from the server connection GUI
func on_server_connect(url: String):
	
	if url.is_valid_ip_address():
		var peer = NetworkedMultiplayerENet.new()
		print("[INFO] Connecting to server ...")
		peer.create_client(url, DEFAULT_PORT)
		get_tree().set_network_peer(peer)
	else:
		print("[INFO] Attempted connection to invalid IP.")

# Avatar loading GUI
func on_change_avatar(path):
	$You/Avatar.begin_load_avatar(path)
	
	# Also start a thread to send the avatar to everyone else
	var sender_thread = Thread.new()
	sender_thread.start(self, "send_avatar_async", path, 0)


## AVATAR TRANSFERS

func send_avatar_async(path):
	var file = File.new()
	file.open(path, File.READ)
	var buffer = file.get_buffer(file.get_len()).compress()
	file.close()
	
	rpc("client_loaded_avatar", buffer)

# Clientside; another user changed avatars
remote func client_loaded_avatar(buffer):
	var id = get_tree().get_rpc_sender_id()
	print("[INFO] Downloading avatar from " + id)
	
	var file = File.new()
	var path = "res://Avatars/" + gen_unique_string(8) + ".vrm"
	file.open(path, File.WRITE)
	file.store_buffer( buffer.decompress( buffer.len() ) )
	file.close()
	
	#debug, later this will be loaded into the other player
	players[id].get_node("Avatar").begin_load_avatar(path)

# Utility for generating filenames
var ascii_letters_and_digits = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
func gen_unique_string(length: int) -> String:
	var result = ""
	for i in range(length):
		result += ascii_letters_and_digits[randi() % ascii_letters_and_digits.length()]
	return result


## WORLD DOWNLOADING

# The server wants the clients to download a world
remote func on_world_change(url):
	$HTTPRequest.set_download_file("temp/world.pck")
	var err = $HTTPRequest.request(url)
	if err:
		print("[ERROR] Server changed to world at " + url + ", but it couldn't be downloaded.")
		get_tree().set_network_peer(null) # Just disconnect I guess
		return
	print("[INFO] Server changed worlds, downloading from " + url + " ...")
	
	# Change to a loading world?

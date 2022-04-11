extends Peer
class_name Server

var DEFAULT_MAX_PEERS = 80

onready var main = get_tree().get_root().get_node("Spatial")

# Called when the node enters the scene tree for the first time.
func _ready():
	
	var port = DEFAULT_PORT
	if "--port" in OS.get_cmdline_args():
		pass
	
	var max_peers = DEFAULT_MAX_PEERS
	if "--max-users" in OS.get_cmdline_args():
		pass
	
	var peer = NetworkedMultiplayerENet.new()
	print("[INFO] Starting server...")
	peer.create_server(port, max_peers)
	get_tree().set_network_peer(peer)
	assert(get_tree().is_network_server())
	
	print("[INFO] Server running on port " + str(port))


# A client wants the server to change the world
remote func request_change_world(url):
	if not get_tree().is_network_server(): # Should be a server if you're getting this signal
		print("[WARNING] Received request to change the world, but we aren't the server")
		return
	
	# Make sure the user has world change permission
	var id = get_tree().get_rpc_sender_id()
	# ...
	
	# Validate the URL?
	
	$HTTPRequest.set_download_file("temp/world.pck")
	var err = $HTTPRequest.request(url)
	if err:
		print("[INFO] User " + str(id) + " requested world at " + url + ", but it couldn't be downloaded.")
		return
	print("[INFO] User " + str(id) + " changed world to " + url + ", downloading...")
		
	# Tell the clients to download it as well (maybe just transfer them the file after instead?)
	rpc("on_world_change", url)

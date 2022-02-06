extends Spatial

var DEFAULT_PORT = 8777
var DEFAULT_MAX_PEERS = 80

var is_server: bool
var players = {}
var client = null
var current_world

var default_world = preload("res://DefaultAssets/DefaultWorld.tscn")
var player_scene = preload("res://TestPlayer.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# Start in the default world
	current_world = default_world.instance()
	add_child(current_world)
	
	if OS.has_feature("Server") or "--server" in OS.get_cmdline_args():
		is_server = true
		
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
		print("[INFO] Server running on port " + str(port))
		
	else:
		is_server = false
		
		var VRClient_scene = load("res://VRClient/VRClient.tscn")
		client = VRClient_scene.instance()
		add_child(client)
		
	
	get_tree().connect("network_peer_connected", self, "_user_connected")
	get_tree().connect("network_peer_disconnected", self,"_user_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	
	$HTTPRequest.connect("request_completed", self, "_on_request_completed")



## KEEP TRACK OF OTHER PLAYERS

func _user_connected(id):
	# Spawn a scene for this player
	players[id] = player_scene.instance()
	add_child(players[id])
	print("[INFO] Player " + str(id) + " connected.")

func _user_disconnected(id):
	# Destroy the player's scene
	players[id].queue_free()
	players.erase(id)
	print("[INFO] Player " + str(id) + " disconnected.")
	
# Called from other clients that are moving around
remote func update_remote_tracker_pos(head_pos, lhand_pos, rhand_pos, tracker_pos_arr):
	var id = get_tree().get_rpc_sender_id()
	players[id].update_transform(head_pos, lhand_pos, rhand_pos, tracker_pos_arr)



## CLIENTSIDE CONNECT / DISCONNECT

# Callback from SceneTree, only for clients (not server).
func _connected_ok():
	var id = get_tree().get_network_unique_id()
	#client.set_network_master( id )
	print("[INFO] Connected to server.")

# Callback from SceneTree, only for clients (not server).
func _server_disconnected():
	get_tree().set_network_peer(null)
	print("[INFO] Server disconnected.")

# Callback from SceneTree, only for clients (not server).
func _connected_fail():
	get_tree().set_network_peer(null) # Remove peer
	print("[INFO] Failed to connect to server.")

# Called from the server connection GUI
func try_connect(url: String):
	
	if url.is_valid_ip_address():
		var peer = NetworkedMultiplayerENet.new()
		print("[INFO] Connecting to server ...")
		peer.create_client(url, DEFAULT_PORT)
		get_tree().set_network_peer(peer)
	else:
		print("[INFO] Attempted connection to invalid IP.")



## WORLD LOADING

# Called from the load world GUI (on a client)
func change_server_world(url):
	rpc_id(1, "request_change_world", url)

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
		print("[INFO] User requested world at " + url + ", but it couldn't be downloaded.")
		return
		
	# Tell the clients to download it as well (maybe just transfer them the file after instead?)
	rpc("on_world_change", url)
	

# The server wants the clients to download a world
remote func on_world_change(url):
	$HTTPRequest.set_download_file("temp/world.pck")
	var err = $HTTPRequest.request(url)
	if err:
		print("[Error] Server changed to world at " + url + ", but it couldn't be downloaded.")
		get_tree().set_network_peer(null) # Just disconnect I guess
		return
		
	# Change to a loading world?


# We're done downloading a world
func _on_request_completed(result, response_code, headers, body):
	# Not sure how to load the world so that the server and all clients are synced
	var success = ProjectSettings.load_resource_pack("res://temp/world.pck") #This may replace files
	
	# Check the world at all? Filter nodes out of it? Remove scripts?
	
	remove_child(current_world)
	current_world = load("res://world.tscn").instance()
	add_child(current_world)

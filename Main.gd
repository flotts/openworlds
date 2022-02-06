extends Spatial

var DEFAULT_PORT = 8777
var DEFAULT_MAX_PEERS = 80

var is_server: bool
var players = {}
var client = null
var current_world

var default_world = load("res://DefaultAssets/DefaultWorld.tscn")
var player_scene = load("res://TestPlayer.tscn")
var VRClient_scene = load("res://VRClient/VRClient.tscn")

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
		print("[INFO] Server running on port " + port)
		
	else:
		is_server = false
		
		client = VRClient_scene.instance()
		add_child(client)
		
	
	get_tree().connect("network_peer_connected", self, "_user_connected")
	get_tree().connect("network_peer_disconnected", self,"_user_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _player_connected(id):
	# Spawn a scene for this player
	players[id] = player_scene.instance()
	add_child(players[id])

func _player_disconnected(id):
	# Destroy the player's scene
	players[id].queue_free()
	players.erase(id)
	

# Callback from SceneTree, only for clients (not server).
func _connected_ok():
	print("[INFO] Connected to server.")

# Callback from SceneTree, only for clients (not server).
func _server_disconnected():
	get_tree().set_network_peer(null)
	print("[INFO] Server disconnected.")

# Callback from SceneTree, only for clients (not server).
func _connected_fail():
	get_tree().set_network_peer(null) # Remove peer
	print("[INFO] Failed to connect to server.")

func try_connect(url: String):
	if url.is_valid_ip_address():
		var peer = NetworkedMultiplayerENet.new()
		print("[INFO] Connecting to server ...")
		peer.create_client(url, DEFAULT_PORT)
		get_tree().set_network_peer(peer)
	else:
		print("[INFO] Attempted connection to invalid IP.")

puppet func update_remote_tracker_pos(head_pos, lhand_pos, rhand_pos, tracker_pos_arr):
	var id = get_tree().get_rpc_sender_id()
	players[id].update_transform(head_pos, lhand_pos, rhand_pos, tracker_pos_arr)

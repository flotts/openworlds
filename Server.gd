extends Node

var DEFAULT_MAX_PEERS = 80

onready var main = get_tree().get_root().get_node("Spatial")

# Called when the node enters the scene tree for the first time.
func _ready():
	var port = main.DEFAULT_PORT
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


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

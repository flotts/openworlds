extends Spatial

# A client is something that keeps a list of players, and keeps track of them spatially.

var DEFAULT_WORLD = preload("res://DefaultAssets/DefaultWorld.tscn")
var PLAYER_SCENE = preload("res://RemotePlayer/TestPlayer.tscn")
var DEFAULT_PORT = 8777

var players = {}
var current_world


# Called when the node enters the scene tree for the first time.
func _ready():
	
	# Start in the default world
	current_world = DEFAULT_WORLD.instance()
	add_child(current_world)
	
	get_tree().connect("network_peer_connected", self, "_user_connected")
	get_tree().connect("network_peer_disconnected", self,"_user_disconnected")
	
	$HTTPRequest.connect("request_completed", self, "_on_request_completed")


func _user_connected(id):
	# Spawn a scene for this player
	players[id] = PLAYER_SCENE.instance()
	add_child(players[id])
	print("[INFO] Player " + str(id) + " connected.")
	
func _user_disconnected(id):
	# Destroy the player's scene
	players[id].queue_free()
	players.erase(id)
	print("[INFO] Player " + str(id) + " disconnected.")
	
# We're done downloading a world ?
func _on_request_completed(result, response_code, headers, body):
	print("[INFO] Request finished: " + str(result) + "\t" + str(headers))
	# Not sure how to load the world so that the server and all clients are synced
	var success = ProjectSettings.load_resource_pack("res://temp/world.pck") #This may replace files
	
	# Check the world at all? Filter nodes out of it? Remove scripts?
	
	remove_child(current_world)
	current_world = load("res://world.tscn").instance()
	add_child(current_world)


# Called from other clients that are moving around
remote func update_remote_tracker_pos(head_pos, lhand_pos, rhand_pos, tracker_pos_arr):
	var id = get_tree().get_rpc_sender_id()
	players[id].update_transform(head_pos, lhand_pos, rhand_pos, tracker_pos_arr)

# Remote player added a tracker
remote func remote_tracker_activated(tracker_id):
	pass

# Remote player removed a tracker
remote func remote_tracker_deactivated(tracker_id):
	pass

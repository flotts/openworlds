extends Node

var server = null
var client = null

func _ready():
	# Use the args to decide which client to spawn
	
	if OS.has_feature("Server") or "--server" in OS.get_cmdline_args():
		var server_scene = load("res://Server.tscn")
		server = server_scene.instance()
		add_child(server)
		
	else:
		var vr_client_scene = load("res://Clients/OVRClient.tscn")
		client = vr_client_scene.instance()
		add_child(client)

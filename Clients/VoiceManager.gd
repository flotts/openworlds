extends Node

signal created_instance(id)
signal removed_instance(id)

onready var peer = get_node("..")

export var muted: bool = false setget _set_muted
var instances = {}
var _id = null


func _ready() -> void:
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	get_tree().connect("connection_failed", self, "_server_disconnected")

	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")

#func _physics_process(delta: float) -> void:
#	if (!get_tree().has_network_peer() || !get_tree().is_network_server()) && _id == 1:
#		_reset() # Still confused

## SIGNALS

func _connected_ok() -> void:
	#if (!get_tree().has_network_peer() || !get_tree().is_network_server()) && _id == 1:
	#	_reset() # What lol why would you have id 1 if you arent network server
	
	_create_instance(get_tree().get_network_unique_id())

func _server_disconnected() -> void:
	_reset()

func _player_connected(id) -> void:
	if id != 1:
		call_deferred("_create_instance", id)

func _player_disconnected(id) -> void:
	if id != 1:
		_remove_instance(id)
		
func _set_muted(value):
	if _id != null:
		instances[_id].recording = value

	muted = value

func _received_voice_data(data: PoolRealArray, id: int) -> void:
	emit_signal("received_voice_data", data, id)

func _sent_voice_data(data: PoolRealArray) -> void:
	emit_signal("sent_voice_data", data)


## MANAGE INSTANCES

func _create_instance(id: int) -> void:
	var instance := VoiceInstance.new()
	
	instance.connect("received_voice_data", self, "_received_voice_data")
	instance.name = str(id)
	instances[id] = instance

	if id == get_tree().get_network_unique_id():
		instance.recording = !muted
		instance.listen = false # change later?
		instance.input_threshold = 0.005

		instance.connect("sent_voice_data", self, "_sent_voice_data")

		_id = id
		
	else:
		instance.custom_voice_audio_stream_player = peer.players[id].voice.get_path()


	add_child(instance)

	emit_signal("created_instance", id)

func _remove_instance(id: int) -> void:
	var instance: VoiceInstance = instances[id]

	if id == _id:
		_id = null

	instance.queue_free()
	instances.erase(id)

	emit_signal("removed_instance", id)

func _reset() -> void:
	for id in instances.keys():
		_remove_instance(id)

extends Spatial


onready var trackers = $Trackers.get_children()

var ws

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func apply_world_scale():
	var new_ws = ARVRServer.world_scale
	if (ws != new_ws):
		ws = new_ws
		$Head.scale = Vector3(ws, ws, ws)
		$Left_Hand.scale = Vector3(ws, ws, ws)
		$Right_Hand.scale = Vector3(ws, ws, ws)
		for t in trackers:
			t.scale = Vector3(ws, ws, ws)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func update_transform(head_pos, lhand_pos, rhand_pos, tracker_pos_arr):
	if head_pos:
		$Head.transform = head_pos
	if lhand_pos:
		$Left_Hand.transform = lhand_pos
	if rhand_pos:
		$Right_Hand.transform = rhand_pos
	for t in range(tracker_pos_arr.size()):
		if tracker_pos_arr[t]:
			trackers[t] = tracker_pos_arr[t]

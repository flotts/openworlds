extends Spatial


onready var trackers = $Trackers.get_children()

var ws

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

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

extends Spatial


onready var trackers = $Trackers.get_children()
onready var voice = $Head/VoicePlayer

# var ws

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

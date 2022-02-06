extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func update_transform(head_pos, lhand_pos, rhand_pos, tracker_pos_arr):
	if head_pos:
		get_node("Head").transform = head_pos
	if lhand_pos:
		get_node("Left_Hand").transform = lhand_pos
	if rhand_pos:
		get_node("Right_Hand").transform = rhand_pos
	for tracker in range(tracker_pos_arr.size()):
		if tracker_pos_arr[tracker]:
			get_node("Trackers").get_children()[tracker] = tracker_pos_arr[tracker]

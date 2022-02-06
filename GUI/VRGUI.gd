extends StaticBody


onready var _viewport = get_child(0)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Send player's keyboard input to the viewport
func _input(event):
	if event is InputEventKey:
		_viewport.input(event)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

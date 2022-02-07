extends Panel


onready var url_text = get_node("LineEdit")


func _on_Button_pressed():
	get_tree().get_root().get_node("Spatial").change_server_world(url_text.text)

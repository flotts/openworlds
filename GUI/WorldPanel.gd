extends Panel

signal on_world_change(url)

onready var url_text = get_node("LineEdit")


func _on_Button_pressed():
	emit_signal("on_world_change", url_text.text)

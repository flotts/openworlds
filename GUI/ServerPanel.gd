extends Panel

signal on_connect(ip)

onready var ip_text = get_node("LineEdit")


func _on_Button_pressed():
	emit_signal("on_connect", ip_text.text)

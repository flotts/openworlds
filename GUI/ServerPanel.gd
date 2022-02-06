extends Panel


onready var ip_text = get_node("LineEdit")


func _on_Button_pressed():
	get_tree().get_root().get_node("Spatial").try_connect(ip_text.text)

extends Panel



func _on_Button_pressed():
	$FileDialog.popup()


func _on_FileDialog_file_selected(path):
	get_tree().get_root().get_node("Spatial").change_avatar(path)

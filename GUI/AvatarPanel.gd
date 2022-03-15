extends Panel

signal on_change_avatar(path)

func _on_Button_pressed():
	$FileDialog.popup()


func _on_FileDialog_file_selected(path):
	emit_signal("on_change_avatar", path)

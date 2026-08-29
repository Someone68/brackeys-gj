extends StaticBody2D
@export_multiline var dialogue : Array[String]

func interact():
	Global.show_dialog(dialogue)

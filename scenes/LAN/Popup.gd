extends Panel


var change
@onready var button : Button= $NinePatchRect/VBoxContainer/HBoxContainer/OkButton
@onready var textfield : LineEdit = $NinePatchRect/VBoxContainer/HBoxContainer/TextField
@onready var label = $NinePatchRect/VBoxContainer/LabelPopUp
# Called when the node enters the scene tree for the first time.
signal sPopupFinished
func setUp(inicio : String):
	
	label.text = inicio
	textfield.text = ""
	textfield.grab_focus()
	show()

 


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):$$
#	pass


func _on_OkButton_pressed():
	send()


func _on_text_field_text_submitted(new_text):
	send()

func send():
	var text : String = textfield.text.left(30)
	emit_signal("sPopupFinished",label.text,text)
	



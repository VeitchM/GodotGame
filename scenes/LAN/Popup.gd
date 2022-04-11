extends Panel


var change
onready var button : Button= find_node("OkButton")
onready var textfield : LineEdit = find_node("TextField")
onready var label = find_node("LabelPopUp")
# Called when the node enters the scene tree for the first time.
signal popupFinished
func setUp(inicio : String):
	
	label.text = inicio
	textfield.text = ""
	textfield.grab_focus()
	show()

 


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_OkButton_pressed():
	send()


func _on_TextField_text_entered(new_text):
	send()

func send():
	var text : String = textfield.text.left(30)
	emit_signal("popupFinished",label.text,text)
	

extends Node



func _ready():
	inMainMenu()


#esto capaz se deberia pasar a la  entidad que cambie de escena
func inMainMenu():
	get_node("../MainMenu/ControllerMainMenu").connect("pressedMainMenu",self, "pressedMainMenu")

#	pass
func pressedMainMenu(button):
	if button == "Host" :
		get_node("../").hostMenu()
	else:
		if button == "Join" :
			get_node("../").joinMenu()
#reemplazar por switch y todos los botones que pueda tener

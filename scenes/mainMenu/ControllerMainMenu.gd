extends Node



signal pressedMainMenu
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#Backcontroller = get_tree().get_root().get_node("Main/Controller") #si hago la asignacion arriba, todavia no se esta conectado al arbol
	



func _on_Host_Button_pressed():
	emit_signal("pressedMainMenu","Host")



	
	


func _on_Join_Button_pressed():
	emit_signal("pressedMainMenu","Join")

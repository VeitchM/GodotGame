extends HBoxContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var serverInfo
var label : Label
signal joinServer
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func setUp(gameInfo):
	label = get_node("NinePatchRect2/serverName")
	label.text = "%s || IP : %s" %[gameInfo.name,gameInfo.ip] 
	serverInfo = gameInfo
	


func _on_joinServer_pressed():
	OnlineModule.joinServer(serverInfo)
	emit_signal("joinServer")
	#Liberar el buscador, y serverListener

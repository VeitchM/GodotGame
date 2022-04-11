extends Control


# Declare member variables here. Examples:
# var a = 2
var serverListener : Node
onready var visibleServersGUI : VBoxContainer = get_node("NinePatchRect/VBoxContainer/PartidasYBotones/PartidasVisibles") # The box which contain the servers name and its buttons to join
var serversGUIReferences = {} #A dictionary with the nodes in the box, maybe it doesn't justify itself


func _ready():
	pass
	

func initialize():
	print("ServerListener assigned")
	serversGUIReferences = {}
	for server in visibleServersGUI.get_children():
		server.queue_free()
	serverListener= OnlineModule.get_node("ServerListener")
	
	serverListener.connect("removeServer",self, "_removeServer") #Logica de bajo nivel, la interfaz de red de Server Listener
	serverListener.connect("newServer", self, "_newServer")
	

	
func _removeServer(ipAddress):
	serversGUIReferences[ipAddress].queue_free()

func _newServer(gameInfo):
	var server : BoxContainer = load(Repository.Rutes["Servers"]).instance()
	server.setUp(gameInfo)
	#server.initialize(gameInfo) I will try to initialize with the ready
	print("Se percibio algo")
	serversGUIReferences[gameInfo.ip] = server
	visibleServersGUI.add_child(server)
	server.connect("joinServer",get_node("../"),"_joinServer") #Se conectara con el control del menu de lobby
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

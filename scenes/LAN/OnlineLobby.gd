extends Control


const HOST : int = 1
var estadoMenu : int = HOST
var playerID : int = HOST
var playersCount : int = HOST
@onready var selfPath = self.get_path()

@onready var hostJoin = get_node("HostJoin")
@onready var buscar = get_node("Buscar")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#OnlineModule.connect("peer",self,"_addChatMessage") no se que era


func setUp(setUp) -> int: #returns 1 if fails
	
	if setUp == "Join": # tosqueado para que solo haga host
		OnlineModule.searchServers()
		initializeSearcher()
		hostJoin.hide()
		buscar.show()
		return 0
	elif setUp == "Host":	
		if !OnlineModule.host():
			hostJoin.initialize()
			return 0
	elif setUp== "JoinedToServer":
		buscar.hide()
		hostJoin.initialize()
		return 0
	return 1	
	
func _joinServer():
	setUp("JoinedToServer")

func initializeSearcher():
	buscar.initialize()
		



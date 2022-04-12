extends Node

class Player:
	var id : int = 0
	var playerName : String = "Jorge"
	var ready : bool = false
	var ping : int = 0
	
	func sendFormat():
		return [id,playerName,ready]
	
	static func loadSendFormat(vector):
		var player = Player.new()
		player.id = vector[0]
		player.playerName = vector[1]
		player.ready = vector[2]
		return player
		

	
var network = ENetMultiplayerPeer.new()
const CLIENTPORT : int = 1997 
const SERVERPORT : int = 1961
const MAXPLAYER :int = 64
var isServer : bool = false

var IPADRESS : String  = ""
var actualPlayerInfo : Player = Player.new()
var serverName : String = "Jorge" 
var playersInfo : Dictionary = {} 
var matchInfo 

@onready var levelSync = load("res://logic/Online/LevelSync.gd").new()

signal sAddChatMessage
# warning-ignore:unused_signal
signal sAddPlayerInfo
signal sRemovePlayer
signal sDisconnected
# warning-ignore:unused_signal
signal sRefreshPlayerInfo
signal sRefreshServerInfo

#toDO server se cae

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(levelSync)
	if OS.get_name() == "Android":
		IPADRESS = IP.get_local_addresses()[0] #no estoy seguro como funciona esto sin NAT
	else:
		#to do con antena era el 5 ahora es el ip 3 
		IPADRESS=IP.get_local_addresses()[3]
	print(IPADRESS)
	#IPADRESS = "127.0.0.1" #LoopBack
	

func get_IPadress() -> String:
	return IPADRESS



func host() -> int: #Start the host systems, if fails it returns 1
	if network.create_server(SERVERPORT, MAXPLAYER):
		print("Server failed to start")
		return 1
	else:
		get_tree().multiplayer = network
		print("Server started succesfully")
		isServer = true
		actualPlayerInfo.id = network.get_unique_id()
		network.peer_connected.connect(self._peer_connected)
		network.peer_disconnected.connect(self._peer_disconnected)
		add_child(   load(Repository.Rutes["ServerAdvertiser"]).instantiate())
		return 0
	
	#playersInfo[actualPlayerInfo.id] = actualPlayerInfo #it's better to have it appart


func searchServers():
	print(Repository.Rutes["ServerListener"])
	add_child ( load(Repository.Rutes["ServerListener"]).instantiate() )
	print("Server listened added to tree")
	

func connectToHost( ip ):
		network.create_client(ip, SERVERPORT)
		get_tree().set_network_peer(network)
		network.connection_failed.connect(self._connection_failed)	
		network.connection_succeeded.connect(self._connection_succeeded)
		network.server_disconnected.connect(self._server_disconnected)
		actualPlayerInfo.id= network.get_unique_id()

func _connection_failed():
	print("Connection to server has failed")
	emit_signal("disconnected")
	
func _connection_succeeded():
	print("connection succeded!")


func sendPlayerInfo(id):
	rpc_id(id,"addsPlayerInfo",actualPlayerInfo.sendFormat())
	print("quize enviar Playerinfo")

@rpc 
func addPlayerInfo(player): #imperative remote function to add a player 
	var signalv
	var playerInfo = Player.loadSendFormat(player)	
	if playersInfo.has(playerInfo.id):
		signalv ="sRefreshPlayerInfo"
	else:	
		signalv= "sAddPlayerInfo"
	print(playerInfo.id, playerInfo)
	
	playersInfo[playerInfo.id] = playerInfo 
	emit_signal(signalv,playerInfo)
	#maybe i should not use a dictionary for this, it's not so long 
	print("se agrego playerInfo de id %s y nombre %s" %[playerInfo.id, playerInfo.playerName])

func _peer_connected(id):
	sendServerInfo(id)
	print("Client connected ",id)

func sendServerInfo(id):
	var serverInfo = {}
	serverInfo.playersInfo = []
	for player in playersInfo.values():
		serverInfo.playersInfo.append(player.sendFormat()) 
	mostrarPlayersInfo(playersInfo)
	serverInfo.playersInfo.append(actualPlayerInfo.sendFormat())
	serverInfo.serverName = serverName
	serverInfo.matchInfo = matchInfo #Podria agragar el chat
	print("Envie server Info")
	rpc_id(id,"refreshServerInfo",serverInfo)	 # Este metodo solo lo deberia tener el servidor
	
func mostrarPlayersInfo(playersDict):
	print("Cantidad en dictionaries :", playersDict.values().size() )
	for player in playersDict.values():
		print(player.id," ",player.playerName )
	
@rpc
func refreshServerInfo(serverInfo):# toDO Solo cliente, se llama cuando conecta al hostlobby
	playersInfo = {}
	var loadedPlayer : Player
	for player in serverInfo.playersInfo:
		loadedPlayer = Player.loadSendFormat(player)
		playersInfo[loadedPlayer.id] = loadedPlayer
	print("Se entro en refreshServerInfo")
	if playersInfo.has(actualPlayerInfo.id):
		if !playersInfo.erase(actualPlayerInfo.id):
			print("OnlineModule: playersInfo hasn't erased correctly")
	mostrarPlayersInfo(playersInfo) #debug	
	serverName = serverInfo.serverName
	matchInfo = serverInfo.matchInfo
	emit_signal("sRefreshServerInfo")
	sendPlayerInfo(network.TARGET_PEER_BROADCAST)


	

	
	
func _peer_disconnected(id): #servidor
	print("Client %s disconnected", playersInfo[id].playerName)
	erasePlayer(id)
	rpc("erasePlayer",id)

@rpc
func erasePlayer(id):
	if !playersInfo.erase(id):
		print("OnlineModule: playersInfo hasn't erased correctly")
	emit_signal("removePlayer",id)

func _server_disconnected():
	print("ServerDisconnected")
	playersInfo = {}
	#supongo que todo lo de la network se manejara solo
	emit_signal("disconnected")

func sendChatMessage(target, message):
	if target == "everybody":
		rpc("addChatMessage",message) #I should use something to do groups like rpc_id(peer_id,method,parameter)
		
@rpc
func addChatMessage(message):
		print("Se Recibio el mensaje: %s \nDesde el peer con id: %s" %[message.id,message.text])
		emit_signal("sAddChatMessage",message)
		
		
func joinServer(gameInfo):
	#matar serverListener, y ventana de buscar
	
	get_node("ServerListener").queue_free()
	connectToHost(gameInfo.ip)


func getPlayerName(id : int) -> String :
	var player:Player  = getPlayer(id)
	if player == null:
		return "UserNotFound"
	return player.playerName

func getPlayer(id : int) -> Player:
	#print("el id recibido fue ",id)
	if id == actualPlayerInfo.id:
		return actualPlayerInfo
	elif playersInfo.has(id):
		return playersInfo[id]
	else:
		return null

func getPlayerId() -> int:
	return actualPlayerInfo.id

func _changeServerName(newServerName):
	#the easiest way
	serverName = newServerName
	sendServerInfo(network.TARGET_PEER_BROADCAST)#medio pesado

func _changePlayerName(newPlayerName):
	actualPlayerInfo.playerName = newPlayerName
	sendPlayerInfo(network.TARGET_PEER_BROADCAST)






#::::::::Functionalities: Ping, Time ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#the servers sends it's time each time it answer the client


@rpc
func receiveAnswerPing(info):
	#info[0] : id, info[1] : time
	getPlayer(info[0]).ping =  Time.get_ticks_msec() - info[1]

var deltaServerTime : int = 0

func correctServerTime(time : int):
	#deltaServerTime = 0.1 * ( (time - OS.get_ticks_msec) - deltaServerTime) #toDo think about kind of linear interpolation, but is int
	deltaServerTime = time - Time.get_ticks_msec()

func getServerTime() -> int : #Time in the server corrected by ping
	return Time.get_ticks_msec() + deltaServerTime -actualPlayerInfo.ping
	
#::::::::Shooter Module::::::::::::::::::::::::::::::::::::::::::::::::::::::::	
#::::::::::::::::::::::::InGame Functionalities:::::::::::::::::::::::::::::::::::::::

func sendPlayerInfoInGame(playerInfo : Array): # send self
	if actualPlayerInfo.id != 1:# if not the server
		rpc_id(1, "receivePlayerInfoInGameServer",playerInfo) #should it be reliable toThink 


@rpc
func receivePlayerInfoInGameServer(infoToServer):#method used by server to receive the information from the players
	#toDo make it a thread
	#print("receivedInfoFromPlayer")
	LevelsManager.onlineSyncs.receivedInfoFromPlayer(BaseCharacter.CharacterForServer.getInfoToServer(infoToServer))

var debugData
@rpc
func receiveInfoToClient(data): #Message from server to clients with the processed data of all players
		debugData =data
		rpc("receiveAnswerPing",[actualPlayerInfo.id,data[0]])
		correctServerTime(data[0])
		var playerInfo : BaseCharacter.CharacterToClient
		#var aux = {"serverTimeStamp" : data[0]}
		for player in data[1]:
			playerInfo = BaseCharacter.getInfoToClientByPlayer(player)
			if playerInfo.id == actualPlayerInfo.id:
				LevelsManager.onlineSyncs.playerChar.serverCorrectionInfo = playerInfo
			else:
				LevelsManager.onlineSyncs.puppets[playerInfo.id].controlate(playerInfo)
	

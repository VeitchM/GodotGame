class_name OnlineSyncs

#::For Server::::::::::::
var playersLastDataReceived : Dictionary = {} # of type baseCharacter CharacterForServer
var playersDataToClient : Dictionary# of type CharacterToClient
var sortedCharKeys : Array 
var threadSender : bool = true
var thread : Thread
var sentTime : float = 10000 #change if there are players
#::For Both:::::::::::::
var puppets : Dictionary 
var level : Node3D 
var playerChar : PlayerCharacter 

func initialize(scene):#same for client and server, it puts players in its places
	level = scene
	print("Initialize OnlineSyncs")
	playerChar = load("res://characters/player/PlayerCharacter.tscn").instantiate()
	playerChar.id = OnlineModule.actualPlayerInfo.id
	var puppetScript 
	if OnlineModule.isServer:
		puppetScript = load("res://characters/3PCharacter/slave/slaveCharacter.tscn")
	else:
		puppetScript = load("res://characters/3PCharacter/puppet/puppetCharacter.tscn")
	var puppetChar# toDo put the type: 

#Adds the characters in the world, i dont know where
	scene.call_deferred("add_child",playerChar)
	for player in OnlineModule.playersInfo.values():
		puppetChar = puppetScript.instantiate() #toDo maybe i should put a factory here
		puppetChar.id = player.id
		scene.call_deferred("add_child", puppetChar)
		if OnlineModule.isServer:
			playersLastDataReceived[player.id] = BaseCharacter.CharacterForServer.new() #forServer
			#playersDataToClient[player.id] = {} #forServer
		puppets[player.id] = puppetChar

	# Putting each character in a define place, the same for every computer	
	sortedCharKeys = OnlineModule.playersInfo.keys()
	sortedCharKeys.append(OnlineModule.actualPlayerInfo.id)
	sortedCharKeys.sort()
	
	# Selecting character based on key and iterate
	var charac : BaseCharacter
	var i : int = 0
	for key in sortedCharKeys:
		if puppets.has(key):
			charac = puppets[key]
		else:
			if key == OnlineModule.actualPlayerInfo.id:
				charac =  playerChar
		if !charac == null:
			charac.position = scene.playerSpawns[i]
			i+=1
		else:
			print("Player key not found to relocate")
	thread  = Thread.new()
	thread.start(self.threadSendInfoToClient)
	
#::For Server::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

func receivedInfoFromPlayer(player : BaseCharacter.CharacterForServer ):
	if !( player.clientTimeStamp > playersLastDataReceived[player.id].clientTimeStamp ): #if this information newer? toDo or critic, reload shoot
		print("Paquete tirado")
	puppets[player.id].order(player) #puppet = slave in this case


func threadSendInfoToClient(_a):
	print("ThreadSendInfo")
	while threadSender:
		await LevelsManager.get_tree().create_timer(sentTime).timeout
		sendInfoToClient()
		
	thread.call_deferred("wait_to_finish")

var debugData

func sendInfoToClient():
	#var aux = []
	#for player in playersDataToClient.values(): #is it necessary ?
	#	aux.append_array(player)
	var data = [Time.get_ticks_msec()]
	#data.append_array(aux)	
	data.append(playersDataToClient.values())
	debugData =  data

	
	OnlineModule.rpc("receiveInfoToClient",data)
	print("InfoToPlayerSended")



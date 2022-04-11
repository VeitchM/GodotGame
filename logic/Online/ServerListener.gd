extends Node


signal newServer
signal removeServer

var cleanUpTimer = Timer.new()
var socketUDP = PacketPeerUDP.new()
var listenPort = OnlineModule.CLIENTPORT

var knownServers = {}

export (int) var serverCleanUpThreshold = 3 # no se para que se exporta

func _init():
	cleanUpTimer.wait_time = serverCleanUpThreshold
	cleanUpTimer.one_shot = false
	cleanUpTimer.autostart = true
	cleanUpTimer.connect("timeout",self,"_cleanUp") 
	add_child(cleanUpTimer)

# Called when the node enters the scene tree for the first time.
func _ready():
	knownServers.clear()
	if socketUDP.listen(listenPort) != OK:
		print("GameServer Lan Service: Error linstening on port "+ str(listenPort))
	else:
		print("GameServer Lan Service: Linstening on port "+ str(listenPort))
		_process(0)

func _process(delta):
	#print("Cantidad de Packets ",socketUDP.get_available_packet_count(),
	#"\nSocket ip %" %ip )
	if socketUDP.get_available_packet_count()>0:# si le pongo 8 tarda como 8 seg
		var serverIP = socketUDP.get_packet_ip()
		var serverPort = socketUDP.get_packet_port()
		var stream = socketUDP.get_packet()
		print(stream.get_string_from_ascii())
		
		if serverIP != "" and serverPort > 0:
			if not knownServers.has(serverIP):
				var serverMessage = stream.get_string_from_ascii()
				var gameInfo = parse_json(serverMessage)
				gameInfo.ip = serverIP
				gameInfo.lastSeen = OS.get_unix_time()
				knownServers[serverIP] = gameInfo
				print("new server %s" %serverIP)
				emit_signal("newServer",gameInfo) #esto sera escuchado por la ui pertinente
			
			else:
				print(OS.get_unix_time())
				knownServers[serverIP].lastSeen = OS.get_unix_time()


#se encarga de verificar que servers no responden hace rato y borrarlos
func _cleanUp():
	var now = OS.get_unix_time()
	for serverIP in knownServers:
		if(now - knownServers[serverIP].lastSeen) > serverCleanUpThreshold:
			knownServers.erase(serverIP)
			print('Remove old server: %s ' %serverIP)
			emit_signal("removeServer",serverIP) #esto sera escuchado por la ui pertinente
			
	
	
func _exit_tree():
	socketUDP.close()
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

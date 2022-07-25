extends Node

#este nodo enviara mensajes a los demas jugadores de que esta hosteando una partida
@export var  BROADCAST_INTERVAL : float = 1.0

var serverInfo = {"name" : "LAN Game" }
var socketUDP
var broadcastTimer = Timer.new()
var broadcastPort = OnlineModule.CLIENTPORT

func _enter_tree():
	broadcastTimer.wait_time = BROADCAST_INTERVAL
	broadcastTimer.one_shot = false
	broadcastTimer.autostart = true
	
	if is_multiplayer_authority(): #no entiendo esta verificacion
		add_child(broadcastTimer)
		broadcastTimer.timeout.connect(self.broadcast)
		
		socketUDP = PacketPeerUDP.new()
		socketUDP.set_broadcast_enabled(true)
		print ("Se ha podido generar socketUDP" ,socketUDP.set_dest_address("255.255.255.255",broadcastPort)) #esa IP es la que se usa para broadcast global

func broadcast():
	serverInfo.name = OnlineModule.serverName
	socketUDP.put_packet(PackedByteArray([serverInfo]))
	#print(serverInfo)
	#print(parse_json( packetMessage.get_string_from_ascii()) )
	

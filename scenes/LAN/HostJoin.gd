extends Control


var estate : int 
onready var playersInfo : VBoxContainer = get_node("NinePatchRect/VBoxContainer/HBoxContainer/VBoxContainer/PlayersInfo")
onready var chat = get_node("NinePatchRect/VBoxContainer/HBoxContainer/VBoxContainer/ChatSystem/Chat") 
onready var chatInput = find_node("chatInput") #puede ser mas prolijo
onready var serverName : Button = find_node("ServerName")
onready var playerNameChat : Label = get_node("NinePatchRect/VBoxContainer/HBoxContainer/VBoxContainer/ChatSystem/ChatInput/PlayersName")
onready var popup : Node = find_node("Popup")

 
var playerID
signal changeServerName
signal changePlayerName
signal readyHostJoin #toDo

func _ready():
	OnlineModule.connect("addChatMessage",self,"_addChatMessage")
	OnlineModule.connect("refreshPlayerInfo",self, "_refreshPlayerInfo") #toDO
	OnlineModule.connect("addPlayerInfo",self, "_addPlayerInfo") #toDo
	OnlineModule.connect("refreshServerInfo",self, "_refreshServerInfo") #toDo
	OnlineModule.connect("removePlayer",self,"_remove_player")
	print("Level manager ",self.connect("readyHostJoin",OnlineModule.levelSync,"_readyHostJoin"))#settings toDo
	popup.connect("popupFinished",self,"_popupFinished")

	refreshOwnName()
func initialize():
	popup.hide()
	serverName.text = OnlineModule.serverName
	for player in playersInfo.get_children(): #desprolijo capaz en un lugar se deberia terminar bien
		player.queue_free()
	addOwnPlayer()
	playerNameChat.text = OnlineModule.actualPlayerInfo.playerName.left(15)
	connect("changeServerName",OnlineModule,"_changeServerName")#solo lo debe poder hacer el servidor toDO
	connect("changePlayerName",OnlineModule,"_changePlayerName")
	show()
	
func addOwnPlayer():
	playerID()
	var me = load ("res://scenes/LAN/myPlayer.tscn").instance()
	me.initialize(playerID())
	playersInfo.add_child(me)	
	me.connect("changePlayerName",self, "_changePlayerName")

func _addPlayerInfo(playerInfo):
	var panel = load ("res://scenes/LAN/otherPlayer.tscn").instance()
	panel.initialize(playerInfo.id)
	playersInfo.add_child(panel)
	
func _refreshPlayerInfo(playerInfo):
	changePlayerName(playerInfo.id,playerInfo.playerName)
	#for player in playersInfo.get_childre()
	#	if	por ahora solo recargo el nombre toDo

func playerID(): 
	 playerID=OnlineModule.actualPlayerInfo.id
	 return playerID

func refreshOwnName():
	playerNameChat.text = OnlineModule.actualPlayerInfo.playerName
	
func _refreshServerInfo():
		serverName.set_text(OnlineModule.serverName)
		refreshPlayers() 
		refreshMatchSettings()

func refreshPlayers():
	for player in playersInfo.get_children():
		if player.id != OnlineModule.actualPlayerInfo.id:
			player.queue_free()
	var aux = OnlineModule.playersInfo.values() 
	for player in aux:
	#for player in OnlineModule.playersInfo:
		var playerUI = load("res://scenes/LAN/otherPlayer.tscn").instance()
		playerUI.initialize(player.id)
		playersInfo.add_child(playerUI)		
		
		
func refreshMatchSettings():
	pass #toDo
		
func _on_chatInput_text_entered(new_text):
	if(new_text!= ""):
		var message = {}
		message.id = playerID()
		message.text = new_text
		_addChatMessage(message)
		chatInput.clear() #It would make more sense if i do this from the button
		OnlineModule.sendChatMessage("everybody",message) # aca se envia
		

func _addChatMessage(message):
	chat.append_bbcode("[b] [" + OnlineModule.getPlayerName(message.id)+ "] [/b] " + message.text +"\n")



	

func _on_ServerName_pressed(): #just the admin should do this
	#inhabilitar todo toDO
	popup.setUp("New Server name")
#aca va la definicion?


func _changePlayerName(): #this is for answering a request, everybody can do this
	popup.setUp("New Player name")


func _popupFinished(funcion,text):
	if funcion == "New Server name":
		serverName.text = text
		emit_signal("changeServerName", text)
	elif funcion == "New Player name":
		emit_signal("changePlayerName", text)
		changePlayerName(playerID,text)
		playerNameChat.text = text.left(15)
		
	popup.hide()
	
func changePlayerName(id,text):
	for player in playersInfo.get_children():
		if player.id== id :
			player.changeName(text)
			
func _remove_player(id):
	for player in playersInfo.get_children():
		if player.id == id:
			player.queue_free()


func _on_ready_pressed():
	emit_signal("readyHostJoin")
	

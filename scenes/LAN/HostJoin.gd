extends Control


var estate : int 
@onready var playersInfo : VBoxContainer = $NinePatchRect/VBoxContainer/HBoxContainer/VBoxContainer/PlayersInfo
@onready var chat = $NinePatchRect/VBoxContainer/HBoxContainer/VBoxContainer/ChatSystem/Chat
@onready var chatInput = $NinePatchRect/VBoxContainer/HBoxContainer/VBoxContainer/ChatSystem/ChatInput/chatInput
@onready var serverName : Button = $NinePatchRect/VBoxContainer/PanelContainer/ServerName
@onready var playerNameChat : Label = $NinePatchRect/VBoxContainer/HBoxContainer/VBoxContainer/ChatSystem/ChatInput/PlayersName
@onready var popup : Node = $Popup

 
var vPlayerID
signal sChangeServerName
signal sChangePlayerName
signal sReadyHostJoin #toDo

func _ready():
	OnlineModule.sAddChatMessage.connect(self._addChatMessage)
	OnlineModule.sRefreshPlayerInfo.connect(self._refreshPlayerInfo) #toDO
	OnlineModule.sAddPlayerInfo.connect(self._addPlayerInfo) #toDo
	OnlineModule.sRefreshServerInfo.connect(self._refreshServerInfo) #toDo
	OnlineModule.sRemovePlayer.connect(self._remove_player)
	print("Level manager ",self.sReadyHostJoin.connect(OnlineModule.levelSync._readyHostJoin))#settings toDo
	popup.sPopupFinished.connect(self._popupFinished)

	refreshOwnName()
func initialize():
	popup.hide()
	serverName.text = OnlineModule.serverName
	for player in playersInfo.get_children(): #desprolijo capaz en un lugar se deberia terminar bien
		player.queue_free()
	addOwnPlayer()
	playerNameChat.text = OnlineModule.actualPlayerInfo.playerName.left(15)
	sChangeServerName.connect(OnlineModule._changeServerName)#solo lo debe poder hacer el servidor toDO
	sChangePlayerName.connect(OnlineModule._changePlayerName)
	show()
	
func addOwnPlayer():
	playerID()
	var me = load ("res://scenes/LAN/myPlayer.tscn").instantiate()
	me.initialize(playerID())
	playersInfo.add_child(me)	
	me.sChangePlayerName.connect(self._changePlayerName)

func _addPlayerInfo(playerInfo):
	var panel = load ("res://scenes/LAN/otherPlayer.tscn").instantiate()
	panel.initialize(playerInfo.id)
	playersInfo.add_child(panel)
	
func _refreshPlayerInfo(playerInfo):
	changePlayerName(playerInfo.id,playerInfo.playerName)
	#for player in playersInfo.get_childre()
	#	if	por ahora solo recargo el nombre toDo

func playerID() -> int:
	vPlayerID=OnlineModule.actualPlayerInfo.id
	return vPlayerID

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
		var playerUI = load("res://scenes/LAN/otherPlayer.tscn").instantiate()
		playerUI.initialize(player.id)
		playersInfo.add_child(playerUI)		
		
		
func refreshMatchSettings():
	pass #toDo
		
func _on_chat_input_text_submitted(new_text):
	if(new_text!= ""):
		var message = {}
		message.id = playerID()
		message.text = new_text
		_addChatMessage(message)
		chatInput.clear()
		OnlineModule.sendChatMessage("everybody",message) # aca se envia
		

func _addChatMessage(message):
	chat.append_text("[b] [" + OnlineModule.getPlayerName(message.id)+ "] [/b] " + message.text +"\n")



	

func _on_ServerName_pressed(): #just the admin should do this
	#inhabilitar todo toDO
	popup.setUp("New Server name")
#aca va la definicion?


func _changePlayerName(): #this is for answering a request, everybody can do this
	popup.setUp("New Player name")


func _popupFinished(funcion,text):
	if funcion == "New Server name":
		serverName.text = text
		emit_signal("sChangeServerName", text)
	elif funcion == "New Player name":
		
		changePlayerName(vPlayerID,text)
		playerNameChat.text = text.left(15)
		
	popup.hide()
	
func changePlayerName(id,text):
	emit_signal("sChangePlayerName", text)
	for player in playersInfo.get_children():
		if player.id== id :
			player.changeName(text)
			
func _remove_player(id):
	for player in playersInfo.get_children():
		if player.id == id:
			player.queue_free()


func _on_ready_pressed():
	emit_signal("sReadyHostJoin")
	




func _on_text_field_text_submitted(new_text):
	pass # Replace with function body.

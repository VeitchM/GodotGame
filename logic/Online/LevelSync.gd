extends Node

class_name LevelSync

func _readyHostJoin():
	ready()
	tryToLoadLevel()

func ready(): #add to the own list the status of the current player as loaded and send that info to all the peers
	rpc("addReadyHostJoin",OnlineModule.actualPlayerInfo.id)
	OnlineModule.actualPlayerInfo.ready= true

@rpc
func addReadyHostJoin(id):
	addReadyPlayer(id)
	tryToLoadLevel()	

func addReadyPlayer(id): #set the status of the parameter player as loaded, and tryToStarLevel() 
	var pointer = OnlineModule.playersInfo[id]
	if pointer!= null:
		pointer.ready= true
	else:
		print("Error: Player not found in method addReadyPlayer")

func tryToLoadLevel(): #If all the player had started the level the map will start
	if allPlayerReady():
		setAllReady(false)
		LevelsManager.loadLevel()

func allPlayerReady():
	print("AllPlayerReady func")
	if !OnlineModule.actualPlayerInfo.ready:
		return false
	for player in OnlineModule.playersInfo.values(): # if anyone is not loaded it wil return false
		
		if !player.ready:
			print("Player not ready")
			return false
		print("Player ready")
	print("All players are ready")
	return true


func setAllReady(val : bool): # set ready values of play
	for player in OnlineModule.playersInfo.values(): # if anyone is not loaded it wil return false
		player.ready= val
	OnlineModule.actualPlayerInfo.ready = val

func levelLoaded(): #set status ready as true and try to start level
	OnlineModule.actualPlayerInfo.ready=true
	print("SettedTrue")
	rpc("addReadyLevelLoaded",OnlineModule.actualPlayerInfo.id)
	tryToStartLevel()#has to be synced toDO maybe verify from the last that has been ready and send rpc

@rpc
func addReadyLevelLoaded(id): #Executed when other player has loaded the map
	addReadyPlayer(id)
	print("From remote")
	tryToStartLevel()

func tryToStartLevel(): #if each player include itself is ready startsLevel
	if allPlayerReady():
		setAllReady(false)
		LevelsManager.startLevel()


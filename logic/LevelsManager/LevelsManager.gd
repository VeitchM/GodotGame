extends Node

var scenePath : String = "res://Game/testWorld.tscn"
var actualScene : Node 
const STATSINGAME : int = 1
const MENUINGAME : int = 2
const ACTUALSCENE : int = 3
var levelStarted : bool = false
signal startLevel

var statsInGame 
var menuInGame  
var onlineSyncs: OnlineSyncs
#to Do manage disconnected signal
func _ready():
	var loader = Thread.new()
	loaderThreaded("res://scenes/OnlineStats/OnlineStats.tscn",STATSINGAME)
	loaderThreaded("res://scenes/InGameMenu/InGameMenu.tscn", MENUINGAME)

func loaderThreaded(path : String, ObjectToLoad : int): #load in a thread, and put in the tree toDo more generic couldnt be called from any object and the objects decides be its own method where to assign it
	var loader = Thread.new()
	loader.start(self,"loaderForThread",[loader,path,ObjectToLoad])
	#loaderForThread([loader,path,ObjectToLoad])

func loaderForThread(vector):#Method intended to be call from a thread injection Danger
	var ownThread :Thread = vector[0]
	var path :String = vector[1]
	var LOADEDOBJECT : int = vector[2]
	var scene = load(path).instance()
	if LOADEDOBJECT == STATSINGAME:
		statsInGame = scene
		call_deferred("add_child",scene)
		print("StatsInGame added to tree")
	elif LOADEDOBJECT == MENUINGAME:
		menuInGame = scene
		call_deferred("add_child",scene)
		print("menuInGame added to tree")
	elif LOADEDOBJECT == ACTUALSCENE:
		actualScene = scene
		onlineSyncs = load("res://logic/LevelsManager/OnlineSyncs.gd").new()
		onlineSyncs.initialize(scene)
		print("level Loaded")
		OnlineModule.levelSync.levelLoaded()
		
	else:
		ownThread.call_deferred("wait_to_finish")
		return	#breack toDo
	
		
	ownThread.call_deferred("wait_to_finish")

func startLevel(): #Put in the tree the actualScene, toDo verify to be idempotent
	print("startLevel")
	emit_signal("startLevel")
	statsInGame.start()
	call_deferred("add_child",actualScene)


func loadLevel(): #Method answering start game, it loads the game and calls the OnlineModule.levelSync.levelLoaded() to noticed that the level has been loaded
	if !levelStarted:
		levelStarted=true
		print("loadLevel")
		loaderThreaded(scenePath,ACTUALSCENE)# it would change of parameter toDo
		
		print("Scene has Loaded")
	

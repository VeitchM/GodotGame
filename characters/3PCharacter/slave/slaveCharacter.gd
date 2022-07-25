extends TPCharacter

#This is a Server side instance of other's player character
class_name SlaveCharacter

@onready var repository : Dictionary = LevelsManager.onlineSyncs.playersDataToClient
var mutexOrders: Mutex = Mutex.new()
var orders : Array = []

func _init():
	super._init()

func _ready():
	super._ready()
	set_physics_process(true)
	pass

func order(player : BaseCharacter.CharacterForServer):
	mutexOrders.lock()
	orders.push_back(player)
	mutexOrders.unlock()

func getOrder(): #I putted  -> BaseCharacter.CharacterForServer but give error teoria de colas me dice que se arma una cola infinita
	mutexOrders.lock()
	var aux = orders.pop_front()
	if aux == null:
		aux = CharacterForServer.new()
	mutexOrders.unlock()	
	if orders.size() > 5:
		print("Acumulado Packetes id: ", id)
	return aux
	
func _physics_process(delta):
	#if the physic process already started when the message started will be used in the next step
	baseCharPhysics(delta)
	useInfoToServer(getOrder())
	
	repository[id] = infoToClient() 
	

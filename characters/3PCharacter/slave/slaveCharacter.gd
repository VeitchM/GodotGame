extends TPCharacter
class_name SlaveCharacter

onready var repository : Dictionary = LevelsManager.onlineSyncs.playersDataToClient
var mutexOrders: Mutex = Mutex.new()
var order : Array = []

func _ready():
	set_physics_process(true)
	pass

func order(player : CharacterForServer):
	mutexOrders.lock()
	order.push_back(player)
	mutexOrders.unlock()

func getOrder()->CharacterForServer: #teoria de colas me dice que se arma una cola infinita
	mutexOrders.lock()
	var aux = order.pop_front()
	if aux == null:
		aux = CharacterForServer.new()
	mutexOrders.unlock()	
	if order.size() > 5:
		print("Acumulado Packetes id: ", id)
	return aux
	
func _physics_process(delta):
	 #if the physic process already started when the message started will be used in the next step
	baseCharPhysics(delta)
	useInfoToServer(getOrder())
	
	repository[id] = infoToClient() 
	

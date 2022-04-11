extends KinematicBody
class_name BaseCharacter #abstract


var animationController 
onready var lookPivot : Spatial = $LookPivot
onready var rayCast : RayCast = $LookPivot/RayCast
#You must asignate this value in the instance of any not abstract sublass

const MAX_SPEED=10
const JUMPVELOCITY = 10
const runningspeed = 10
const hookVel = .3
const airFriction = 1#it changeALittle bit the behavior with gravity
const maxRunningSpeed = 4

const JUMPSTATE :int = 1
const SHOOTSTATE :int = 1<<1
const RELOADSTATE : int = 1<<2

const ONESHOTSTATES = JUMPSTATE+SHOOTSTATE+RELOADSTATE
var mutex :Mutex = Mutex.new()

var normal : Vector3 = Vector3(0,1,0)
var isFalling : bool  #use for verify if it was falling in the preview instant


var id : int
var charState : CharState


class CharState: #It has the variables velocity : Vector3 position : Vector3 walk: Vector3 rotation : Vector2 action : int v action : int health : float timestamp : int
	var velocity : Vector3
	var position : Vector3
	var walk: Vector3
	var rotation : Vector2
	var char_state : int = 0
	var action : int #action and action are maybe the same could be useful later, if I use each bit i have 32 ocurrence and it mixtures
	var health : float
	var serverTimeStamp = 0 # assigned by server
	var clientTimeStamp
	var jump : float
	
	func newAction() -> int: #it creates a value where any action is done. This values is 0
		return 0
		
	func addAction(NewAction :int): #it add an action to the current actions that are be done. It works with an OR at binarie level 
		action = action | NewAction  
		
	func hasAction(_action : int):
		return action && _action > 0

	func _init(_pos, _rot, _vel, _action, _char_state, _health):
		position = _pos
		rotation = Vector2(0,0)
		velocity = _vel
		char_state = _char_state
		action = _action
		health = _health

		
		
#func running(direction :Vector3): linear interpolation better
#	var newVelocity = direction+charState.velocity	
#	if newVelocity.length() > maxRunningSpeed:
#		charState.velocity = newVelocity * maxRunningSpeed / newVelocity.length()
#	else:
#		charState.velocity= newVelocity


#:::::::::::::::::::::OnlineFunctions::::::::::::::::::::::::::

#::CharToServer::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#send in a compressed way to server, to improve, maybe just for player
var jumpSended : float = 0

func infoToServer() -> Array: #send in a compressed way to server, to improve
	var aux =  [id, charState.serverTimeStamp, OS.get_ticks_msec(), charState.position,charState.walk,charState.action, jumpSended,Vector2(lookPivot.rotation.x,rotation.y)] #toDo, hookFunctionalities.hookInfoToServer()]
	if jumpSended>0:
		print("JumpSended")
	jumpSended = 0
	return aux

class CharacterForServer:
	var id : int = 1 #Is important to be the server id, because of slave implematation
	var serverTimeStamp : int = 0
	var clientTimeStamp : int = 0
	var position  :Vector3
	var walk :Vector3
	var action : int
	var jump : float
	var rotation : Vector2 = Vector2(0,0)


	static func getInfoToServer(infoToServer):  #get the compresed information maybe i could unified getInfoToServer and useInfoToServer
		var aux = CharacterForServer.new()
		aux.id =  infoToServer[0]
		aux.serverTimeStamp = infoToServer[1]
		aux.clientTimeStamp = infoToServer[2]
		aux.position =  infoToServer[3]
		aux.walk = infoToServer[4]
		aux.action = infoToServer[5]
		aux.jump = infoToServer[6]
		if aux.jump>0:
			print("jump received")
		aux.rotation = infoToServer[7]
		return aux

func useInfoToServer(info : CharacterForServer):
	charState.serverTimeStamp = info.serverTimeStamp
	charState.clientTimeStamp = info.clientTimeStamp #toDo Calculate Lag
	charState.walk = info.walk
	charState.action = charState.action || info.action #or toDo concurrency problem
	charState.jump += info.jump
	if charState.jump > 0:
		print("jumpdata executed : ",charState.jump)
	turn(info.rotation)

#::CharForClient::::::::::::::::::::::::::::::::::::::::::::::::
class CharacterToClient:
	var id : int = 0
	var ping : int 
	var position  :Vector3
	var walk :Vector3
	var action : int
	var jump : float
	var velocity : Vector3
	var rotation : Vector2 = Vector2(0,0)

func infoToClient():#toDo think about time
	return [id, OnlineModule.getPlayer(id).ping, charState.position, charState.walk, charState.action, charState.jump, charState.velocity, Vector2(lookPivot.rotation.x,rotation.y) ]

static func getInfoToClientByPlayer(info) -> CharacterToClient:
	var aux = CharacterToClient.new()
	aux.id =info[0]
	aux.ping = info[1]
	aux.position = info[2]
	aux.walk = info[3]
	aux.action = info[4]
	aux.jump = info[5]
	aux.velocity = info[6]
	aux.rotation = info[7]
	return aux 

func useInfoToClient(player :CharacterToClient):
	charState.position = player.position
	charState.walk = player.walk
	charState.action = player.action
	charState.jump = player.jump
	charState.velocity = player.velocity
	turn(player.rotation)
	
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
var hookFunctionalities : Hook 

func _init():
	#set_physics_process(false)
	print(name, " base Character init ",get_instance_id() )
	charState = CharState.new(Vector3.ZERO,Vector2.ZERO,Vector3.ZERO,0,0,1)	


func _ready():
	set_physics_process(false) # starts here because is the first moment when is connected to Physics server
	print(name, " base Character ready ",get_instance_id() )
	hookFunctionalities = load("res://characters/functionalities/Hook.gd").new()
	print("hookLoaded")
	hookFunctionalities.addChilds(get_parent())
	charState.position = translation
	
func hook():
	hookFunctionalities.hook(rayCast,translation)

func changeHookLength(length: float):
	hookFunctionalities.changeLength(length)


func fallingAndFriction(delta): #Verifies if it is falling in that case add velocity and in the other add the friction to velocity and assign a counter normal velocity
	if not is_on_floor():
		isFalling = true
		charState.velocity += WorldProperties.gravity*delta / airFriction
	else:
		normal = get_floor_normal()
	#	if isFalling == true : before it just verify if it was falling once and assigned velocity
		charState.velocity -= normal # + charState.velocity.project(normal) 
		isFalling = false
		charState.velocity += friction(delta)		


func friction(delta) -> Vector3 :
	var relativeVel = charState.velocity - get_floor_velocity() 
	#print("the floors go %f %f %f " %[get_floor_velocity().x, get_floor_velocity().y, get_floor_velocity().z] )
	var friction : Vector3= -relativeVel.slide(normal)
	if friction.length() >  WorldProperties.mu * delta: #The first part is to know the parallalel component of the velocity with the "floor" negative toDO in the future add multiples mu, deppending on the material
		return friction.normalized() * WorldProperties.mu * delta
	else:
		return friction

#::::::::Movement:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

func running(direction : Vector3,delta): #With a given direction(not necessary normalized) it considere if it's falling or not and make an interpolation and change the walk velocity value 
	var velocity = get_floor_velocity()
	if not isFalling:
		direction = direction.slide(normal)
		if  ( velocity - charState.velocity ).dot(direction) < maxRunningSpeed :
			charState.walk =  charState.walk.linear_interpolate(direction * runningspeed ,  delta * 5) 
	else:
		charState.walk =  charState.walk.linear_interpolate(direction * runningspeed*.3 ,  delta * 30)	


func jump(): #Add velocity to jump , add the previus walk speed to velocity, assign zero to walk and initialize the animation of jumpiing of the animation controller
	if charState.jump >0 and !isFalling:
		jumpSended = charState.jump
		charState.velocity += normal * charState.jump + charState.walk
		charState.walk = Vector3.ZERO
		charState.jump = 0
		animationController.jump()
		
	else:
		charState.jump=0 # maybe not

func turn(_rotation : Vector2):
	var rotationSpeed = charState.rotation - _rotation
	animationController.turn(rotationSpeed)
	charState.rotation = _rotation
	rotation.y = _rotation.y
	lookPivot.rotation.x = _rotation.x
	

#:::::::::::::Weapon related::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

func reload(): #for now it just initialize the animation in animation controller
	animationController.reload()
	#toDo all functionalities

func shot(): #for now it just initialize the animation in animation controller
	animationController.shot()

func baseCharPhysics(delta): #simulates velocity, it has to be calculated only by the server and the player for his character
	#toDo maybe use a thread
	charState.velocity = ( translation - charState.walk *delta - charState.position  )/delta
	charState.position = translation

	fallingAndFriction(delta)
	charState.velocity += hookFunctionalities.hookVelocityModifier(translation)
	jump()
	# Lo de restarle la velocidad del piso lo hago porque sino es dificil el manejo de la friccion

	
func _physics_process(delta):
	#print(name, " base Character _physics_process ",get_instance_id() )
	move_and_slide( charState.velocity + charState.walk - get_floor_velocity() ,Vector3.UP)
	animationController.movementSpeed(charState.walk) #Where i send it it knows its global rotation
	hookFunctionalities.render(translation)


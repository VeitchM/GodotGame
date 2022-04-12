extends BaseCharacter

class_name PlayerCharacter
var MOUSE_SENSITIVITY : float = 0.2

var  jumpForce :float= 0


var dataByServer
var serverCorrectionInfo
##################################ServerOnly################################################
@onready var repository : Dictionary = LevelsManager.onlineSyncs.playersDataToClient
###########################################################################################


signal newPlayersData

func _init():
	super._init()
	print(name, " Player init ",get_instance_id() )#if not used the physic process starts before all is on place
	# set_physics_process(false)
func _ready():
	#set_physics_process(false)
	super._ready()
	print(name, " Player ready ",get_instance_id() )
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	animationController = $LookPivot/POV
	print(name, " Player finishing ready ",get_instance_id() )
	set_physics_process(true)


	
	
	
	
func _input(event):
	if event is InputEventMouseMotion and is_physics_processing():
		rotate_y(deg2rad(-1 * event.relative.x * MOUSE_SENSITIVITY))
		lookPivot.rotate_x(deg2rad(event.relative.y )* MOUSE_SENSITIVITY)
		lookPivot.rotation.x = clamp(lookPivot.rotation.x,deg2rad(-90), deg2rad(90)) #capaz permitir hacer packflip
	else:
		if Input.is_action_just_released("jump"):
			if jumpForce > JUMPVELOCITY:
				jumpForce=JUMPVELOCITY
			print("jumpforce ",jumpForce)
			charState.jump=jumpForce
		
		
		
		if Input.is_action_just_pressed("stadistics"):
				LevelsManager.statsInGame.refresh()
				LevelsManager.statsInGame.show()
				
		
		if Input.is_action_just_released("stadistics"):
			LevelsManager.statsInGame.hide()
			LevelsManager.statsInGame.refresh()	
				
		
		if Input.is_action_just_pressed("shot"):
				shot()
				charState.addAction(SHOOTSTATE)
				print("Shot")
		if Input.is_action_just_pressed("reload"):
				reload()
				charState.addAction(RELOADSTATE)
				print("Reload")
		if Input.is_action_just_pressed("hook"):
				hook()
				print("hook")
		
				
func correctionFromServer(loc : Vector3):
		pass

func _physics_process(delta):
	#print(name, " Player Physics ",get_instance_id() )
	correctionFromServer(Vector3(0,0,0))#toDo
	baseCharPhysics(delta)
	running(get_input_direction(),delta)
	if Input.is_action_pressed("jump") and !isFalling: #cambiar a que dependa del tiempo
		jumpForce += 50 * delta
		#toDo animation of loading jump
	else:
		jumpForce = 5
	if jumpForce >5:
		print("jumpforce ",jumpForce)
	hookControls()
	if OnlineModule.isServer:
		LevelsManager.onlineSyncs.playersDataToClient[id] = infoToClient()
	#else:
		#OnlineModule.sendPlayerInfoInGame(infoToServer())
	charState.action = 0
	super._physics_process(delta)
	
func hookControls():
	if Input.is_action_pressed("retractHook"):
			changeHookLength(-hookVel)
	if Input.is_action_pressed("extendHook"):
			changeHookLength(hookVel)
			print("extend")
			
				
func get_input_direction() -> Vector3:
	var z : float = Input.get_action_strength("foward") - Input.get_action_strength("backward")
	var x: float = Input.get_action_strength("left") - Input.get_action_strength("right")
	if Input.get_action_strength("ui_cancel") >0.4:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)#trying to free the mouse
	return transform.basis * Vector3(x,0,z).normalized()
	

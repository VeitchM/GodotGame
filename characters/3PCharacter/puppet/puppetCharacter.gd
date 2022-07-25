extends TPCharacter
class_name puppetCharacter #Used by the client

#This is a Client side instance of other's player character

@onready var repository : Dictionary = LevelsManager.onlineSyncs.playersDataToClient

func _init():
	super._init()

func _ready():
	super._ready()
	set_physics_process(true)
	pass




func controlate(player : BaseCharacter.CharacterToClient):#method for puppets on client	
	useInfoToClient(player)

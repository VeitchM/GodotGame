extends TPCharacter
class_name puppetCharacter #Used by the client

onready var repository : Dictionary = LevelsManager.onlineSyncs.playersDataToClient


func _ready():
	set_physics_process(true)
	pass




func controlate(player : CharacterToClient):#method for puppets on client	
	useInfoToClient(player)

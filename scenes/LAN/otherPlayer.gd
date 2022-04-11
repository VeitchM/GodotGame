extends "res://scenes/LAN/jugadores.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.

func initialize(inputID):
	initializeSuper(inputID)
	playerNameLabel.text = playerName

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

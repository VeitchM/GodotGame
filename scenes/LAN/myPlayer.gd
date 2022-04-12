extends "res://scenes/LAN/jugadores.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
signal sChangePlayerName

func initialize(inputID):

	initializeSuper(inputID)
	playerNameLabel.text = playerName
	print("primero hice initialize")
	






func changePlayerName():
	emit_signal("sChangePlayerName")

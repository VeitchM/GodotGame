extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var Rutes = {"ServerListener" : "res://logic/Online/ServerListener.tscn",
			"OnlineLobby" :	"res://scenes/OnlineLobby.tscn",
			"ServerAdvertiser" : "res://logic/Online/ServerAdvertiser.tscn", 
			"Buscar(Server)" : "res://scenes/mainMenu/Buscar.tscn", # Sino quedaba ambiguo, supongo que usare mas buscar
			"Servers" : "res://scenes/LAN/servers.tscn"
	
}
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

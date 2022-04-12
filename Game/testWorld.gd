extends Node3D


@onready var plataforma : AnimatableBody3D = $Plataforma
var time = 0.0

var playerSpawns = Array([Vector3(0,10,0),Vector3(0,10,10),Vector3(10,10,0),Vector3(10,10,10),Vector3(0,10,20)]) #maybe use resize to reserve memory and make an algorith to assign the points
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func _physics_process(delta): # maybe a threat
	time = OnlineModule.getServerTime() - OnlineModule.actualPlayerInfo.ping # I choose this so the server simulates the same as the player with itself
	plataforma.position.x =  sin( time/800.0) *10.0

extends Control


# Declare member variables here. Examples:
var  MainButtonsMenu = 0
var  PlayMenu = 1
var  SettingsMenu = 2
# var b = "text"
onready var playMenu = get_node("PlayMenu")
onready var menuLAN = get_node("Menu LAN")
onready var mainButtonsMenu = get_node("MainButtonsMenu")
onready var menuLan = get_node("MenuLan")
onready var hostJoin = get_node("MenuLan/HostJoin")

func _ready():
	OnlineModule.connect("disconnected",self,"_disconnected")
	LevelsManager.connect("startLevel",self,"_startLevel")	

func _startLevel():
	hide()

	

	
	

func _disconnected():
	print("Error Disconnected")
	menuLan.hide()
	#cartel de desconectado
	mainButtonsMenu.show()
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Play_pressed():
	mainButtonsMenu.hide()
	playMenu.show()
# Maybe I shouldn't change scene, I can hide the main Buttons VBox and show the play menu


func _on_Back_pressed():
	playMenu.hide()
	MainButtonsMenu.show()


func _on_Quit_pressed():
	#Saves settings
	get_tree().quit()


func _on_Settings_pressed():
	pass # Replace with function body.



func _on_play_pressed():
	print("Que pasa")# Replace with function body.


func _on_Coop_LAN_pressed():
	playMenu.hide()
	menuLAN.show()
	
	


func _on_Host_Button_pressed():
	
	if !menuLan.setUp("Host"):
		menuLAN.hide()
		menuLan.show()


func _on_Join_Button_pressed():
	menuLAN.hide()
	menuLan.setUp("Join")
	menuLan.show()

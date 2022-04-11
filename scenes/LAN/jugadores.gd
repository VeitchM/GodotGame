extends HBoxContainer
class_name PlayerHostJoin
#Abstract 
var id  : int 
var playerName
var playerNameLabel : Node
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func initializeSuper(inputID: int):
	playerNameLabel = find_node("PlayerName") 
	id =  inputID
	playerName = OnlineModule.getPlayerName(inputID)
	changeName(playerName)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func changeName(text):
	playerNameLabel.text=text

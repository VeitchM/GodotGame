extends PlayerHostJoin
class_name StatsInGamePlayerInfo

onready var ping : Label = $Panel3/Ping

func _ready():
	pass

func initialize(ID : int):
	ping = $Panel3/Ping
	initializeSuper(ID)
	ping.text = String(OnlineModule.getPlayer(ID).ping)
	#toDo kills deaths etc

func refresh():
	initialize(id)

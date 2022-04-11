extends Control

onready var players = $Players
func _ready():
	
	pass

func start(): #it adds all the players and get the ping of each one
	print("Started Online Stats")
	var loaded = load("res://scenes/OnlineStats/StatsInGamePlayerInfo.tscn")
	var playerInfoStatsNode = loaded.instance()
	playerInfoStatsNode.initialize(OnlineModule.actualPlayerInfo.id)
	if (playerInfoStatsNode == null):
		print("isNull")
	else:
		print("notNull")
	players.add_child(playerInfoStatsNode)
	for player in OnlineModule.playersInfo.values():
		playerInfoStatsNode = loaded.instance()
		playerInfoStatsNode.initialize(player.id)
		if (playerInfoStatsNode == null):
			print("isNull")
		else:
			print("notNull")
		players.add_child(playerInfoStatsNode)
	

func refresh():
	for player in players.get_children():
		player.refresh()

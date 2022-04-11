extends BaseCharacter
class_name TPCharacter

func _ready():
	animationController =  $LookPivot/POV 

func actions():
	if charState.hasAction(SHOOTSTATE):
		shot()

func _physics_process(delta):
	actions()

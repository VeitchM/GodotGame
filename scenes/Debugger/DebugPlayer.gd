extends Control




@onready var playerCharacter : PlayerCharacter = get_node("../../PlayerCharacter")
@onready var velocity  = $Control/Velocity
@onready var velocity2  = $Control/Velocity2
@onready var walk  = $Control/Walk
@onready var velocityFloor  = $Control/VelocityFloor

var velocityVector : Vector3
var walkVector : Vector3
var vPosition : Vector3
func _ready():
	playerCharacter.sNewPlayersData.connect(self._Update)


func _Update():
	velocityVector = playerCharacter.charState.velocity
	walkVector = playerCharacter.charState.walk
	var velocityFloorVector = playerCharacter.get_floor_velocity()
	
	var realVelocity =- (vPosition - playerCharacter.position) / .01666666
	position = playerCharacter.vPosition
	showVectorPoint(velocityVector,velocity,10)
	showVectorPoint(walkVector,walk,10)
	showVectorPoint(velocityFloorVector,velocityFloor,10)
	showVectorPoint(realVelocity,velocity2,10)
	var vectors : Label= $Control/Panel
	vectors.text = ["VelocityNoWalking : ",velocityVector,"\n Walk", walkVector,"\nFloor Velocity",velocityFloorVector,"\n Position",playerCharacter.position]
	

func showVectorPoint(vector : Vector3, image : Sprite, size : float): #Move a sprite on screen depending on the vector3 given, sized by a value
	image.position = Vector2(vector.x * size + 160, vector.z * size + 160 )
	

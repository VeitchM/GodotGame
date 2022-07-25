extends Control




@onready var playerCharacter : PlayerCharacter = get_node("../../PlayerCharacter")
@onready var gVelocity  = $Control/Velocity
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
	var velocityFloorVector = playerCharacter.get_platform_velocity()
	
	var realVelocity =- (vPosition - playerCharacter.position) / .01666666
	vPosition = playerCharacter.position
	showVectorPoint(velocityVector,gVelocity,10)
	showVectorPoint(walkVector,walk,10)
	showVectorPoint(velocityFloorVector,velocityFloor,10)
	showVectorPoint(realVelocity,velocity2,10)
	var vectors : Label= $Control/Panel
	vectors.text = "Is falling %s" %playerCharacter.isFalling +"\n RealVelocity: %f %s" %[realVelocity.length(), realVelocity ]  #+ realVelocity.length().str()
	vectors.text+="\n VelocityNoWalking : %s" %velocityVector + "\n Walk %s" %walkVector + "\nFloor Velocity %s" %velocityFloorVector + "\n Position %s" %playerCharacter.position
	vectors.text +="\n Friction %s" %playerCharacter.frictionDebug 
	vectors.text +="\n Floor Normal %s" %playerCharacter.get_floor_normal() 
	

func showVectorPoint(vector : Vector3, image , size : float): #Move a sprite on screen depending on the vector3 given, sized by a value
	image.position = Vector2(vector.x * size + 160, vector.z * size + 160 )
	

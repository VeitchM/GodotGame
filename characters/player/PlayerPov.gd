extends AnimationController
class_name PlayerPov

@onready var handsAnimationTree = $riggedHandAcceptable/AnimationTree
@onready var weaponAnimationTree =$riggedHandAcceptable/Armature/Skeleton3D/BoneAttachment3D/riggedRevolverAcceptable/AnimationTree


# Called when the node enters the scene tree for the first time.


func movementSpeed(velocity :Vector3):
	handsAnimationTree.set("parameters/Speed/blend_position",velocity.length()/5-1 ) 
	
func shot():
	print("He disparado")
	handsAnimationTree.set("parameters/Shoot/active",true)
	weaponAnimationTree.set("parameters/Shoot/active",true)

func reload():
	handsAnimationTree.set("parameters/Reload/active",true)
	weaponAnimationTree.set("parameters/Reload/active",true)
	print("recargo")
	
func jump():
	pass

func receiveDamage(damage :  float):

	pass

func die():
	pass

func turn(speed : Vector2):
	pass	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

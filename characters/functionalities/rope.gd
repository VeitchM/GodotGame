extends Spatial




var origin: Vector3
var objective: Vector3
var direction : Vector3
onready var mesh : MeshInstance = $RopeMesh



func _init():
	print("Rope")
	hide()
	

func add(objectiveI: Vector3):
	show()
	objective = objectiveI
	
func render(_origin):
	if visible:  
		var length = (objective - _origin).length()
		mesh.mesh.height =  length
		mesh.translation.z = -length/2
		look_at_from_position (_origin, objective, Vector3.UP )
	
func take():
	hide()

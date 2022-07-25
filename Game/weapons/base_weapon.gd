extends Node
class_name Weapon 
var weaponName : String
var weaponId : int
var damage : float
# Called when the node enters the scene tree for the first time.
func shot(ray : RayCast3D):
	var shotedObject = ray.get_collider()
	print("The shotted was : %s"  %shotedObject)
	if (!!shotedObject):
		decal()
		#print(shotedObject.get_method_list())
		if(shotedObject.has_method("getShoted")):
			print("se disparo a algo")
		shotedObject.getShoted(self)
	pass # Replace with function body.

func decal():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

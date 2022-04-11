class_name Hook

var isHooked : bool = false
var hookPoint : Vector3 = Vector3(0,0,0) # #It sets the local position of the hook in the hooked object
var hookedObject : Spatial
var cableLength : float = 0
var distance: Vector3
var force : Vector3
var aux : float
const elasticK :float = 1.0#2

#to do it could detect colisions and bend

var rope 
const hips : Vector3 = Vector3(0,0,0)

class HookInfoToServer:
	var localHookPoint: Vector3
	var hookedObjectGlobalId: int
	var cableLength: float

func _init():
	print("Hook Init id ", get_instance_id())

func addChilds(object : Node):
	rope = load("res://characters/functionalities/rope.tscn").instance()
	object.call_deferred("add_child",rope)

func hook(rayCast : RayCast, position : Vector3):#It sets the local position of the hook in the hooked object and sets hook = true
	if isHooked == true:
		unHook()
	else:
		hookedObject = rayCast.get_collider()
		if !!hookedObject:
			isHooked = true
			hookPoint = rayCast.get_collision_point() - hookedObject.translation #It sets the local position of the hook in the hooked object
			cableLength = (position-rayCast.get_collision_point()).length()
			#debugger()
		else:
			isHooked = false

func unHook():
	isHooked = false
	rope.take()
	#toDo kind of animation

func changeLength(length):
	if cableLength + length > 2:
		cableLength+= length
	#maybe an animation

func render(position):
	rope.render(position)
	

func hookVelocityModifier(position: Vector3) -> Vector3:  #it will modify the given charState if it's hooked
	if isHooked:
		rope.add(hookPoint + hookedObject.translation)
		distance = rope.objective  - position
		aux= distance.length()
		if aux >= cableLength:
			return elasticK*distance.normalized()*(aux - cableLength)/cableLength #it calculates the force depending of how elongated it's the rope
			#auxWalk = charState.walk.project(force).length()
			#auxVelocity = charState.velocity.project(force).length()
			#charState.walk += force * auxWalk/(auxWalk+auxVelocity)
			#charState.velocity += force * auxVelocity/(auxWalk+auxVelocity)
		
	return Vector3.ZERO	

	


func distributeInfluence(vectors3 ): #calculate a new value
	pass
func debugger():
	print("Is hooked to "+hookedObject.name)
	print("Translation of Object "+String(hookedObject.translation))
	var sphere = preload("res://scenes/Debugger/debuggerSphere.tscn").instance()
	hookedObject.get_parent().call_deferred("add_child",sphere)
	sphere.translation = hookPoint + hookedObject.translation



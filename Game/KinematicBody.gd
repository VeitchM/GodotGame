extends KinematicBody


# Declare member variables here. Examples:
# var a = 2
var velocity : Vector3 = Vector3(0,0,0) 


# Called when the node enters the scene tree for the first time.



func _physics_process(delta):
	if is_on_floor():
		print ("estaEnElPiso")
		velocity.y =0
		print("Is on floor")
	else: 
		velocity.y -= 10*delta
	move_and_slide(velocity)
	if is_on_wall():
		print("is on wall ")

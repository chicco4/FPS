extends RigidBody3D

@onready var label_3d = $Label3D

var health = 20

func hit_successful(damage):
	health -= damage
	
	print(get_name() + " health: " + str(health))
	
	if health <= 0:
		queue_free()

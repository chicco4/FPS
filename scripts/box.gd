extends RigidBody3D

@onready var label_3d = $Label3D

var health = 20

func hit_successful(damage):
	health -= damage
	
	label_3d.set_text(str(health))
	
	if health <= 0:
		queue_free()

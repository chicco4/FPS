extends StaticBody3D

var health = 1

func hit_successful(damage, _direction := Vector3.ZERO, _position := Vector3.ZERO):
	
	health -= damage
	print(get_name() + " health: " + str(health))
	if health <= 0:
		queue_free()

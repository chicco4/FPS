extends RigidBody3D

var health = 20

func hit_successful(damage, _direction := Vector3.ZERO, _position := Vector3.ZERO):
	
	health -= damage
	print(get_name() + " health: " + str(health))
	if health <= 0:
		queue_free()
	
	var hit_position = _position - get_global_transform().origin
	
	if _direction != Vector3.ZERO:
		apply_impulse((_direction * damage), hit_position)

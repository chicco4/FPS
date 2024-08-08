extends RigidBody3D

var damage: int = 0

const BULLET_DEBUG = preload("res://scenes/objects/bullets/bullet_debug.tscn")

func _on_body_entered(body):
	if body.is_in_group("target") and body.has_method("hit_successful"):
		body.hit_successful(damage)
	
	load_decal(get_position())
	queue_free()

func load_decal(position):
	var rd = BULLET_DEBUG.instantiate()
	var world = get_tree().get_root()
	world.add_child(rd)
	rd.global_translate(position)

func _on_timer_timeout():
	queue_free()

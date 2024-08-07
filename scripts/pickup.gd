extends RigidBody3D

@export var weapon_resource: WeaponResource

var pickup_ready: bool = false

@export_enum("weapon", "ammo") var pickup_type: String = "weapon"

func _ready():
	await get_tree().create_timer(2.0).timeout
	pickup_ready = true

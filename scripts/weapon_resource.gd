extends Resource

class_name WeaponResource

@export var weapon_name: String
@export var activate_anim: String
@export var deactivate_anim: String
@export var shoot_anim: String
@export var reload_anim: String
@export var OOA_anim: String

@export var current_ammo: int
@export var reserve_ammo: int
@export var magazine_ammo: int

@export var auto_fire: bool
@export var weapon_range: int
@export var damage: int

@export_flags("hitscan","projectile") var type

@export var projectile_to_load: PackedScene
@export var projectile_velocity: int

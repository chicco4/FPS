extends Node3D

signal weapon_changed
signal update_ammo
signal update_weapon_list

@onready var animation_player = $FPSRig/AnimationPlayer
@export var weapon_list: Array[WeaponResource]

var current_weapon = null
var weapon_index = 0

@onready var bullet_point = $FPSRig/BulletPoint

enum {NULL, HITSCAN, PROJECTILE}

var bullet_debug = preload("res://scenes/bullet_debug.tscn")
var collision_exclusion = []

func _ready():
	current_weapon = weapon_list[weapon_index]
	emit_signal("weapon_changed", current_weapon.weapon_name)
	emit_signal("update_ammo", current_weapon.current_ammo, current_weapon.magazine_ammo)
	emit_signal("update_weapon_list", weapon_list)
	activate()

func _input(event):
	if event.is_action_pressed("shoot"):
		shoot()
	
	if event.is_action_pressed("reload"):
		reload()
	
	if event.is_action_pressed("weapon_right"):
		if(weapon_index + 1 < weapon_list.size()):
			weapon_index = weapon_index + 1
			change_weapon()
	
	if event.is_action_pressed("weapon_left"):
		if(weapon_index - 1 > -1):
			weapon_index = weapon_index - 1
			change_weapon()

func _on_animation_player_animation_finished(anim_name):
	if anim_name == current_weapon.shoot_anim and current_weapon.auto_fire == true:
		if Input.is_action_pressed("shoot"):
			shoot()

func change_weapon():
	if !animation_player.is_playing():
		deactivate()
		current_weapon = weapon_list[weapon_index]
		emit_signal("weapon_changed", current_weapon.weapon_name)
		emit_signal("update_ammo", current_weapon.current_ammo, current_weapon.magazine_ammo)
		activate()

func activate():
		animation_player.queue(current_weapon.activate_anim)

func deactivate():
		animation_player.queue(current_weapon.deactivate_anim)

func shoot():
	if !animation_player.is_playing():
		if current_weapon.current_ammo > 0:
			current_weapon.current_ammo = current_weapon.current_ammo - 1
			
			emit_signal("update_ammo", current_weapon.current_ammo, current_weapon.magazine_ammo)
			animation_player.play(current_weapon.shoot_anim)
			
			var camera_collision = get_camera_collision()
			match current_weapon.type:
				NULL:
					print("weapon type not chosen")
				HITSCAN:
					hitscan_collision(camera_collision)
				PROJECTILE:
					launch_projectile(camera_collision)
				
		else:
			reload()

func reload():
	if !animation_player.is_playing():
		if current_weapon.magazine_ammo > 0 and (current_weapon.reserve_ammo - current_weapon.current_ammo) > 0:
			
			if current_weapon.magazine_ammo >= (current_weapon.reserve_ammo - current_weapon.current_ammo):
				current_weapon.magazine_ammo -= (current_weapon.reserve_ammo - current_weapon.current_ammo)
				current_weapon.current_ammo += (current_weapon.reserve_ammo - current_weapon.current_ammo)
			else:
				current_weapon.current_ammo += current_weapon.magazine_ammo
				current_weapon.magazine_ammo = 0
			
			emit_signal("update_ammo", current_weapon.current_ammo, current_weapon.magazine_ammo)
			animation_player.play(current_weapon.reload_anim)
		
		else:
			animation_player.play(current_weapon.OOA_anim)

func get_camera_collision() -> Vector3:
	var camera = get_viewport().get_camera_3d()
	var vieport = get_viewport().get_size()
	
	var ray_origin = camera.project_ray_origin(vieport/2)
	var ray_end = ray_origin + camera.project_ray_normal(vieport/2) * current_weapon.weapon_range
	
	var new_intersection = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	new_intersection.set_exclude(collision_exclusion)
	var intersection = get_world_3d().direct_space_state.intersect_ray(new_intersection)
	
	if not intersection.is_empty():
		var col_point = intersection.position
		return col_point
	else:
		return ray_end

func hitscan_collision(collision_point):
	var bullet_direction = (collision_point - bullet_point.get_global_transform().origin).normalized()
	var new_intersection = PhysicsRayQueryParameters3D.create(bullet_point.get_global_transform().origin, collision_point + bullet_direction * 2)
	
	var bullet_collision = get_world_3d().direct_space_state.intersect_ray(new_intersection)
	
	if bullet_collision:
		var hit_indicator = bullet_debug.instantiate()
		var world = get_tree().get_root().get_child(0)
		world.add_child(hit_indicator)
		hit_indicator.global_translate(bullet_collision.position)
		
		hit_scan_damage(bullet_collision.collider)

func hit_scan_damage(collider):
	if collider.is_in_group("target") and collider.has_method("hit_successful"):
		collider.hit_successful(current_weapon.damage)

func launch_projectile(point: Vector3):
	var direction = (point - bullet_point.get_global_transform().origin).normalized()
	var projectile = current_weapon.projectile_to_load.instantiate()
	
	var projectile_rid = projectile.get_rid()
	collision_exclusion.push_front(projectile_rid)
	projectile.tree_exited.connect(remove_exclusion.bind(projectile.get_rid()))
	
	bullet_point.add_child(projectile)
	projectile.damage = current_weapon.damage
	projectile.set_linear_velocity(direction * current_weapon.projectile_velocity)
	
func remove_exclusion(projectile_rid):
	collision_exclusion.erase(projectile_rid)

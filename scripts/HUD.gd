extends CanvasLayer

@onready var current_weapon_lbl = $VBoxContainer/HBoxContainer/CurrentWeapon
@onready var current_ammo_lbl = $VBoxContainer/HBoxContainer2/CurrentAmmo
@onready var weapon_list_lbl = $VBoxContainer/HBoxContainer3/WeaponList


func _on_weapon_manager_update_ammo(current_ammo, magazine_ammo):
	current_ammo_lbl.set_text(str(current_ammo) + " / " + str(magazine_ammo))


func _on_weapon_manager_update_weapon_list(weapon_list):
	weapon_list_lbl.set_text("")
	for weapon in weapon_list:
		weapon_list_lbl.text += "\n" + weapon.weapon_name


func _on_weapon_manager_weapon_changed(weapon_name):
	current_weapon_lbl.set_text(weapon_name)

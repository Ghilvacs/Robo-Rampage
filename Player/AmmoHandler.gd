extends Node
class_name AmmoHandler

@export var ammo_label: Label
@export var mag_ammo_label: Label
@export var weapon_handler: Node3D
@onready var pickup_stream_player_3d: AudioStreamPlayer3D = %PickupStreamPlayer3D

var copy_ammo_storage: int

enum ammo_type {
	BULLET,
	SMALL_BULLET
}

var ammo_storage := {
	ammo_type.BULLET: 8,
	ammo_type.SMALL_BULLET: 30,
}

var mag_storage := {
	ammo_type.BULLET: 2,
	ammo_type.SMALL_BULLET: 30
}

func has_ammo(type: ammo_type) -> bool:
	return ammo_storage[type] > 0

func has_ammo_in_mag(type: ammo_type) -> bool:	
	return mag_storage[type] > 0

func is_not_full(type: ammo_type) -> bool:
	if type == ammo_type.BULLET:
		return mag_storage[type] < 2
	else:
		return mag_storage[type] < 30

func use_ammo(type: ammo_type) -> void:
	if has_ammo_in_mag(type):
		mag_storage[type] -= 1
		update_mag_ammo_label(weapon_handler.get_weapon_ammo())

func add_ammo(type: ammo_type, ammount: int) -> void:
	pickup_stream_player_3d.play()
	ammo_storage[type] += ammount
	update_ammo_label(weapon_handler.get_weapon_ammo())

func reload_ammo(type: ammo_type) -> void:
	if type == ammo_type.BULLET:
		copy_ammo_storage = ammo_storage[type]
		ammo_storage[type] -= (2 - mag_storage[type])
		if ammo_storage[type] < 0:
			mag_storage[type] += copy_ammo_storage
			ammo_storage[type] = 0
		mag_storage[type] += (2 - mag_storage[type])	
	else:
		copy_ammo_storage = ammo_storage[type]
		ammo_storage[type] -= (30 - mag_storage[type])
		if ammo_storage[type] < 0:
			mag_storage[type] += copy_ammo_storage
			ammo_storage[type] = 0
		else:
			mag_storage[type] += (30 - mag_storage[type])
	update_ammo_label(weapon_handler.get_weapon_ammo())
	update_mag_ammo_label(weapon_handler.get_weapon_ammo())

func update_ammo_label(type: ammo_type) -> void:
	ammo_label.text = str(ammo_storage[type])

func update_mag_ammo_label(type: ammo_type) -> void:
	mag_ammo_label.text = str(mag_storage[type])

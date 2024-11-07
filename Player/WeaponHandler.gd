extends Node3D

@export var weapon_1: Node3D
@export var weapon_2: Node3D
@export var ammo_handler: AmmoHandler
@export var ammo_type: AmmoHandler.ammo_type
@export var default_weapon_position: Vector3
@export var ads_weapon_position: Vector3
@onready var animation_player_reload: AnimationPlayer = %AnimationPlayerReload
@onready var animation_player_walk: AnimationPlayer = %AnimationPlayerWalk
@onready var scope_texture: TextureRect = %ScopeTexture

func _ready() -> void:
	equip(weapon_1)
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("equip_weapon_1"):
		equip(weapon_1)
	elif event.is_action_pressed("equip_weapon_2"):
		equip(weapon_2)
	elif event.is_action_pressed("equip_next_weapon"):
		next_weapon()
	elif event.is_action_pressed("equip_last_weapon"):
		last_weapon()

func equip(active_weapon: Node3D) -> void:
	animation_player_reload.stop()
	if scope_texture.visible:
		scope_texture.visible = false
	for child in get_children():
		if child == active_weapon:
			child.visible = true
			child.set_process(true)
			child.ammo_handler.update_ammo_label(child.ammo_type)
			child.ammo_handler.update_mag_ammo_label(child.ammo_type)
		else:
			child.visible = false
			child.set_process(false)

func next_weapon() -> void:
	var index = get_current_index()
	index = wrapi(index + 1, 0, get_child_count())
	equip(get_child(index))

func last_weapon() -> void:
	var index = get_current_index()
	index = wrapi(index - 1, 0, get_child_count())
	equip(get_child(index))

func get_current_index() -> int:
	for index in get_child_count():
		if get_child(index).visible:
			return index
	return 0

func get_weapon_ammo() -> AmmoHandler.ammo_type:
	return get_child(get_current_index()).ammo_type

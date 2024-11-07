extends Node3D

@export var fire_rate := 14.0
@export var recoil : float
@export var weapon_mesh: Node3D
@export var weapon_damage: float
@export var muzzle_flash: GPUParticles3D
@export var sparks: PackedScene
@export var automatic: bool
@export var ammo_handler: AmmoHandler
@export var ammo_type: AmmoHandler.ammo_type
@export var weapon_handler: Node3D
@export var has_scope: bool
@onready var cooldown_timer: Timer = $CooldownTimer
@onready var weapon_position: Vector3 = weapon_mesh.position
@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var animation_player_reload: AnimationPlayer = %AnimationPlayerReload
@onready var animation_player_walk: AnimationPlayer = %AnimationPlayerWalk
@onready var smooth_camera: Camera3D = %SmoothCamera
@onready var camera_pivot: Node3D = %CameraPivot
@onready var smg_fire_stream_player: AudioStreamPlayer = %SMGFireStreamPlayer
@onready var sniper_fire_stream_player: AudioStreamPlayer = %SniperFireStreamPlayer
@onready var smg_reload_stream_player: AudioStreamPlayer = %SMGReloadStreamPlayer

func _process(delta: float) -> void:
	if ammo_handler.has_ammo_in_mag(ammo_type):
		if automatic:
			if Input.is_action_pressed("fire"):
				if cooldown_timer.is_stopped():
					shoot()
					smg_fire_stream_player.play()
			else:
				smg_fire_stream_player.stop()
				pass	
		else:
			if Input.is_action_just_pressed("fire"):
				if cooldown_timer.is_stopped():
					sniper_fire_stream_player.play()
					shoot()
			else:
#				sniper_fire_stream_player.stop()
				pass
	else:
		reload()
		
	weapon_mesh.position = weapon_mesh.position.lerp(weapon_position, delta * 10.0)
	if Input.is_action_just_pressed("reload_weapon"):
		reload()

func shoot() -> void:
	ammo_handler.use_ammo(ammo_type)
	muzzle_flash.restart()
	cooldown_timer.start(1.0 / fire_rate)
	var collider = ray_cast_3d.get_collider()
	camera_pivot.rotation.x = lerp(camera_pivot.rotation.x, camera_pivot.rotation.x + recoil, recoil)
	smooth_camera.position.x = lerp(smooth_camera.position.x, smooth_camera.position.x + recoil, 0.3)
	weapon_mesh.position.z += recoil
	if ray_cast_3d.is_colliding():
		if collider is Enemy:
			collider.hitpoints -= weapon_damage
		var spark = sparks.instantiate()
		add_child(spark)
		spark.global_position = ray_cast_3d.get_collision_point()

func reload() -> void:
	if ammo_handler.has_ammo(ammo_type) && ammo_handler.is_not_full(ammo_type):
		animation_player_walk.stop()
		animation_player_reload.play("reload")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	ammo_handler.reload_ammo(weapon_handler.get_weapon_ammo())

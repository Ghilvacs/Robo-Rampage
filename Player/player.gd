extends CharacterBody3D

@export var speed := 8.0
@export var ads_speed: = 20.0
@export var jump_height := 1.0
@export var fall_multiplier := 2.5
@export var max_hitpoints := 100.0
@export var aim_multiplier := 0.7
@onready var camera_pivot: Node3D = $CameraPivot
@onready var damage_animation_player: AnimationPlayer = $DamageTexture/DamageAnimationPlayer
@onready var game_over_menu: Control = $GameOverMenu
@onready var ammo_handler: Node = %AmmoHandler
@onready var smooth_camera: Camera3D = %SmoothCamera
@onready var smooth_camera_fov = smooth_camera.fov
@onready var weapon_camera: Camera3D = %WeaponCamera
@onready var weapon_camera_fov = weapon_camera.fov
@onready var animation_player_reload: AnimationPlayer = %AnimationPlayerReload
@onready var animation_player_walk: AnimationPlayer = $AnimationPlayerWalk
@onready var weapon_handler: Node3D = %WeaponHandler
@onready var crosshair: Control = $CenterContainer/Crosshair
@onready var scope_texture: TextureRect = $ScopeTexture
@onready var walking_stream_player: AudioStreamPlayer = $WalkingStreamPlayer

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var mouse_motion := Vector2.ZERO

var hitpoints: int = max_hitpoints:
	set(value):
		if value < hitpoints:
			damage_animation_player.stop(false)
			damage_animation_player.play("TakeDamage")
		hitpoints = value
		if hitpoints <= 0:
			game_over_menu.game_over()
			
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta: float) -> void:
	var current_weapon = weapon_handler.get_child(weapon_handler.get_current_index())
	if Input.is_action_pressed("aim"):
		crosshair.visible = false
		if current_weapon.has_scope:
			scope_texture.visible = true
			current_weapon.get_child(3).visible = false
			current_weapon.get_child(2).visible = false
			smooth_camera.fov = lerp(
			smooth_camera.fov,
			smooth_camera_fov * aim_multiplier / 4,
			delta * 20.0
			)
		else:
			weapon_handler.transform.origin = weapon_handler.transform.origin.lerp(weapon_handler.ads_weapon_position, 
			ads_speed * delta)
		smooth_camera.fov = lerp(
			smooth_camera.fov,
			smooth_camera_fov * aim_multiplier,
			delta * 20.0
			)
		weapon_camera.fov = lerp(weapon_camera.fov, 
		weapon_camera_fov * aim_multiplier, 
		delta * 20.0
		)
	else:
		crosshair.visible = true
		if current_weapon.has_scope:
			scope_texture.visible = false
			current_weapon.get_child(3).visible = true
			current_weapon.get_child(2).visible = true
		weapon_handler.transform.origin = weapon_handler.transform.origin.lerp(weapon_handler.default_weapon_position, 
		ads_speed * delta)
		smooth_camera.fov = lerp(smooth_camera.fov,
		smooth_camera_fov, 
		delta * ads_speed
		)
		weapon_camera.fov = lerp(weapon_camera.fov,
		weapon_camera_fov, 
		delta * ads_speed
		)

func _physics_process(delta: float) -> void:
	handle_camera_rotation()
	# Add the gravity.
	if not is_on_floor():
		if velocity.y >= 0:
			velocity.y -= gravity * delta
		else:
			velocity.y -= gravity * delta * fall_multiplier

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = sqrt(jump_height * 2 * gravity)

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if !walking_stream_player.playing:
			walking_stream_player.play()
		if animation_player_reload.is_playing():
			animation_player_walk.stop()
		else:
			if Input.is_action_pressed("aim"):
				animation_player_walk.play("walk_ads")
			else:
				animation_player_walk.play("walk")
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		if Input.is_action_pressed("aim"):
			velocity.x *= aim_multiplier
			velocity.z *= aim_multiplier
	else:
		walking_stream_player.stop()
		animation_player_walk.stop()
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			mouse_motion = -event.relative * 0.001
		if Input.is_action_pressed("aim"):
			mouse_motion *= aim_multiplier
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func handle_camera_rotation() -> void:
	rotate_y(mouse_motion.x)
	camera_pivot.rotate_x(mouse_motion.y)
	camera_pivot.rotation_degrees.x = clampf(
		camera_pivot.rotation_degrees.x, -90.0, 90.0
	)
	mouse_motion = Vector2.ZERO

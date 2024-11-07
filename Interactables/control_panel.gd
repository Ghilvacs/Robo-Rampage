extends Area3D

var is_reachable = false
@onready var garage_door: Area3D = %GarageDoor

func _process(delta: float) -> void:
	if is_reachable && Input.is_action_just_pressed("interact"):
		print("door is opening...")
		garage_door.get_child(2).play("door_slide")

func _on_body_entered(body: Node3D) -> void:
	is_reachable = true

func _on_body_exited(body: Node3D) -> void:
	is_reachable = false

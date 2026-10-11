extends StaticBody3D

@onready var cam = $Camera3D
var player

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("exit") and player:
		player.camera.make_current()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func switchCamera():
	if player and player.camera.current == true:
		cam.make_current()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

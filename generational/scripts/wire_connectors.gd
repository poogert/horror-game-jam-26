extends StaticBody3D

var player

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _on_mouse_entered() -> void:
	print(player.wireBeingHeld)
	if player.wireBeingHeld != null:
		player.wireBeingHeld.global_position = global_position
		player.wireBeingHeld = null
		print("this connecter is connected")

func _on_mouse_exited() -> void:
	pass # Replace with function body.

extends StaticBody3D

@onready var wireMesh: MeshInstance3D = $MeshInstance3D
@onready var handler: StaticBody3D = $"."
@onready var wiresCamera: Camera3D = $Camera3D
var isBeingDragged: bool = false
var dragArea: Plane
var startWidth: float = 1.0
var player

func _ready() -> void:
	startWidth = wireMesh.scale.x
	handler.input_event.connect(handleInput)
	player = get_tree().get_first_node_in_group("player")
	
func handleInput(camera: Camera3D, event: InputEvent, _position: Vector3,_normal: Vector3, _shapeIndex: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var dragAreaNormal = -camera.get_global_transform().basis.z
		dragArea = Plane(dragAreaNormal,handler.global_position)
		isBeingDragged = true
		

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		isBeingDragged = false
		
	if event is InputEventMouseMotion and isBeingDragged:
		var camera = wiresCamera
		if not camera: return
		
		var rayOrigin = camera.project_ray_origin(event.position)
		var rayDirection = camera.project_ray_normal(event.position)
		var targetPosition = dragArea.intersects_ray(rayOrigin, rayDirection)
		
		if targetPosition != null:
			stretchObject(targetPosition)
		
	if event.is_action_pressed("exit"):
		player.camera.make_current()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func stretchObject(targetPosition: Vector3) -> void:
	var base = targetPosition - global_position
	var length = base.length()
	
	if length > 0.01:
		#handler.global_position = targetPosition
		wireMesh.look_at(targetPosition, Vector3.UP)
		wireMesh.rotate_object_local(Vector3.RIGHT,deg_to_rad(90))
		wireMesh.scale = Vector3(startWidth,length,startWidth)

func switchCamera():
	if player.camera.current == true:
		wiresCamera.make_current()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

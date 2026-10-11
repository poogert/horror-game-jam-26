extends Node3D

@export var segmentCount: int = 5
@export var segmentRadius: float = 0.35
@export var segmentMass: float = 0.05

@onready var bottomNode: StaticBody3D = $Marker3D/bottom
@onready var topHandler: AnimatableBody3D = $Marker3D/connecter
@onready var wiresCamera: Camera3D = $Camera3D

var isBeingDragged: bool = false
var dragArea: Plane
var player: Node3D

func _ready() -> void:
	topHandler.input_event.connect(handleInput)
	player = get_tree().get_first_node_in_group("player")
	await get_tree().process_frame
	generateWireChain()

func generateWireChain() -> void:
	var startPos = bottomNode.global_position
	var endPos = topHandler.global_position
	var totalVector = endPos - startPos
	
	if totalVector.length() <= 0.05:
		return
		
	var segmentLength = (totalVector.length() / segmentCount) * 1.35
	var stepDirection = totalVector.normalized()
	
	var redMaterial = StandardMaterial3D.new()
	redMaterial.albedo_color = Color(1, 0, 0)
	
	var previousNode: Node3D = bottomNode
	
	for i in range(segmentCount):
		var spawnPos = startPos + stepDirection * ((totalVector.length() / segmentCount) * i + ((totalVector.length() / segmentCount) / 2.0))
		
		var body = RigidBody3D.new()
		body.name = "WireSegment_" + str(i)
		body.mass = segmentMass
		body.gravity_scale = 0.5
		body.input_ray_pickable = true
		
		body.axis_lock_angular_x = false
		body.axis_lock_angular_y = false
		body.axis_lock_angular_z = false
		
		body.collision_layer = 1
		body.collision_mask = 1
		
		add_child(body)
		body.global_position = spawnPos
		body.input_event.connect(handleInput)
		
		var col = CollisionShape3D.new()
		var cylinderShape = CylinderShape3D.new()
		cylinderShape.radius = segmentRadius
		cylinderShape.height = segmentLength
		col.shape = cylinderShape
		body.add_child(col)
		
		var meshInstance = MeshInstance3D.new()
		var cylinderMesh = CylinderMesh.new()
		cylinderMesh.radial_segments = 16
		cylinderMesh.rings = 1
		cylinderMesh.top_radius = segmentRadius
		cylinderMesh.bottom_radius = segmentRadius
		cylinderMesh.height = segmentLength
		meshInstance.mesh = cylinderMesh
		meshInstance.material_override = redMaterial
		body.add_child(meshInstance)
		
		var lookTarget = body.global_position + stepDirection * 2.0
		body.look_at(lookTarget, Vector3.UP)
		body.rotate_object_local(Vector3.RIGHT, deg_to_rad(90))
		
		var joint = Generic6DOFJoint3D.new()
		add_child(joint)
		
		var jointPos = startPos + (stepDirection * (totalVector.length() / segmentCount) * i)
		joint.global_position = jointPos
		
		joint.set_node_a(previousNode.get_path())
		joint.set_node_b(body.get_path())
		
		joint.set_param_x(Generic6DOFJoint3D.PARAM_LINEAR_UPPER_LIMIT, 0.0)
		joint.set_param_x(Generic6DOFJoint3D.PARAM_LINEAR_LOWER_LIMIT, 0.0)
		joint.set_param_y(Generic6DOFJoint3D.PARAM_LINEAR_UPPER_LIMIT, 0.0)
		joint.set_param_y(Generic6DOFJoint3D.PARAM_LINEAR_LOWER_LIMIT, 0.0)
		joint.set_param_z(Generic6DOFJoint3D.PARAM_LINEAR_UPPER_LIMIT, 0.0)
		joint.set_param_z(Generic6DOFJoint3D.PARAM_LINEAR_LOWER_LIMIT, 0.0)
		
		previousNode = body
		
	var finalJoint = Generic6DOFJoint3D.new()
	add_child(finalJoint)
	finalJoint.global_position = topHandler.global_position
	
	finalJoint.set_node_a(previousNode.get_path())
	finalJoint.set_node_b(topHandler.get_path())
	
	finalJoint.set_param_x(Generic6DOFJoint3D.PARAM_LINEAR_UPPER_LIMIT, 0.0)
	finalJoint.set_param_x(Generic6DOFJoint3D.PARAM_LINEAR_LOWER_LIMIT, 0.0)
	finalJoint.set_param_y(Generic6DOFJoint3D.PARAM_LINEAR_UPPER_LIMIT, 0.0)
	finalJoint.set_param_y(Generic6DOFJoint3D.PARAM_LINEAR_LOWER_LIMIT, 0.0)
	finalJoint.set_param_z(Generic6DOFJoint3D.PARAM_LINEAR_UPPER_LIMIT, 0.0)
	finalJoint.set_param_z(Generic6DOFJoint3D.PARAM_LINEAR_LOWER_LIMIT, 0.0)

func handleInput(camera: Camera3D, event: InputEvent, _position: Vector3, _normal: Vector3, _shapeIndex: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var dragAreaNormal = wiresCamera.get_global_transform().basis.z
		dragArea = Plane(dragAreaNormal, topHandler.global_position)
		isBeingDragged = true

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		isBeingDragged = false
		
	if event is InputEventMouseMotion and isBeingDragged:
		var camera = wiresCamera
		if not camera: return
		
		var mousePosition = get_viewport().get_mouse_position()
		var rayOrigin = camera.project_ray_origin(mousePosition)
		var rayDirection = camera.project_ray_normal(mousePosition)
		var targetPosition = dragArea.intersects_ray(rayOrigin, rayDirection)
		
		if targetPosition != null:
			topHandler.global_basis = Basis.IDENTITY
			topHandler.global_position = targetPosition
		
	if event.is_action_pressed("exit") and player:
		player.camera.make_current()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func switchCamera() -> void:
	if player and player.camera.current == true:
		wiresCamera.make_current()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

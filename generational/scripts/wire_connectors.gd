extends StaticBody3D

@onready var wire = $Node3D

@export var numberOfConnections: int
@export var thisMustConnectTo: StaticBody3D
@export var previousConnectedPiece: StaticBody3D
@export var isStart: bool
@export var isEnd: bool

var player
var isPowered: bool = false
var connectedPieces: int
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	if isEnd:
		wire.queue_free()

func _process(_delta: float) -> void:
	if isStart or (previousConnectedPiece and previousConnectedPiece.isPowered == true and numberOfConnections == connectedPieces):
		powerOn()
func _on_mouse_entered() -> void:
	if player.wireBeingHeld != null:
		var wire_script = player.wireBeingHeld.get_parent().get_parent() 
		if wire_script.has_method("generateWireChain"): # Verification step
			wire_script.connecterHoveringOver = self
			print("Hovering over connector...")

func _on_mouse_exited() -> void:
	if player.wireBeingHeld != null:
		var wire_script = player.wireBeingHeld.get_parent().get_parent()
		if wire_script.has_method("generateWireChain") and wire_script.connecterHoveringOver == self:
			wire_script.connecterHoveringOver = null

func powerOn():
	isPowered = true
	if isStart == false:
		print("power on")
	pass

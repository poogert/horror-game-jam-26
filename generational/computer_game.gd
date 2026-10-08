extends Node2D

@onready var buttonSpawnArea = $MarginContainer/MarginContainer

@export var buttonCount: int = 5
func _ready() -> void:
	randomize()
	
	for i in range(buttonCount):
		var button = CheckButton.new()
		
		buttonSpawnArea.add_child(button)
		
		var randomX = randf_range(0.0,1520.0)
		var randomY = randf_range(0.0,880.0)
		
		button.position = Vector2(randomX,randomY)
	

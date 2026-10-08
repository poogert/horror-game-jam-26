extends Node2D

@onready var buttonOn = preload("res://textures/free-check-icon-3278-thumb.png")
@onready var buttonOff = preload("res://textures/x-png-15.png")

@export var buttonCount: int = 5

var spawnedButtons: Array[TextureButton] = []
func _ready() -> void:
		
	for i in range(buttonCount):
		var button = TextureButton.new()
		
		button.ignore_texture_size = true
		button.stretch_mode = TextureButton.STRETCH_SCALE
		button.size = Vector2(64,64)
		button.texture_normal = buttonOff
		button.texture_pressed = buttonOn
		button.toggle_mode = true
		
		add_child(button)
		
		var randomX = randf_range(0.0,1520.0)
		var randomY = randf_range(0.0,880.0)
		button.position = Vector2(randomX,randomY)
		
		spawnedButtons.append(button)
	
	queue_redraw()


func _draw() -> void:
	if spawnedButtons.size() < 2:
		return
		
	var lineSize = Vector2(32,32)
	
	for i in range(spawnedButtons.size() - 1):
		var lStartPosX = spawnedButtons[i].position.x + lineSize.x
		var lStartPosY = spawnedButtons[i].position.y + lineSize.y
		var lEndPosX = spawnedButtons[i + 1].position.x + lineSize.x
		var lEndPosY = spawnedButtons[i + 1].position.y + lineSize.y

		
		draw_line(Vector2(lStartPosX,lStartPosY),Vector2(lEndPosX,lStartPosY), Color.WHITE, 15.0)
		draw_line(Vector2(lEndPosX,lStartPosY),Vector2(lEndPosX,lEndPosY), Color.WHITE, 15.0)

extends Node2D

@onready var DiaBox  = $DialogueUI

func _ready():
	DiaBox.visible = false

func _on_eventbox_body_entered(body: Node2D) -> void:
	DiaBox.visible = true
	print("even triggered")

extends Control

@onready var name_label = $TextboxPanel/NameLabel
@onready var dialogue_label = $TextboxPanel/DialogueLabel

var dialogue_data = []
var current_index = 0
var is_typing = false
var full_text = ""
var char_index = 0
var typing_speed = 0.03

func _ready():
	load_dialogue("res://Dialogue/dialogue.json")
	show_next_line()

func load_dialogue(file_path: String):
	var file = FileAccess.open(file_path, FileAccess.READ)
	var text = file.get_as_text()
	dialogue_data = JSON.parse_string(text)
	current_index = 0

func show_next_line():
	if current_index >= dialogue_data.size():
		print("Dialogue complete")
		return
	
	var entry = dialogue_data[current_index]
	name_label.text = entry.get("speaker", "")
	full_text = entry.get("text", "")
	dialogue_label.text = ""
	char_index = 0
	is_typing = true
	type_next_character()

func type_next_character():
	if char_index < full_text.length():
		dialogue_label.text += full_text[char_index]
		char_index += 1
		await get_tree().create_timer(typing_speed).timeout
		type_next_character()
	else:
		is_typing = false

func _input(event):
	if event.is_action_pressed("ui_accept"):
		if is_typing:
			dialogue_label.text = full_text
			is_typing = false
		else:
			current_index += 1
			show_next_line()

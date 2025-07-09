extends Control

@onready var name_label = $TextboxPanel/NameLabel
@onready var dialogue_label = $TextboxPanel/DialogueLabel
@onready var choice_box = $choice_box
@onready var character_sprite = $CharacterSprite  # Add your sprite node here

var dialogue_data = []
var current_timeline = "intro"
var timeline_index = 0
var timeline_dialogue = []

var is_typing = false
var full_text = ""
var char_index = 0
var typing_speed = 0.03


func _ready():
	load_dialogue("res://Dialogue/dialogue.json")
	load_timeline("intro")


func load_dialogue(file_path: String):
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("Failed to open dialogue file: " + file_path)
		return
	
	var text = file.get_as_text()
	var result = JSON.parse_string(text)
	
	if typeof(result) != TYPE_ARRAY:
		push_error("Dialogue file must be a JSON array.")
		return
	
	dialogue_data = result


func load_timeline(timeline: String):
	current_timeline = timeline
	timeline_index = 0
	
	timeline_dialogue = dialogue_data.filter(func(entry):
		return entry.has("timeline") and entry.timeline == timeline
	)
	
	if timeline_dialogue.is_empty():
		push_error("No dialogue found for timeline: " + timeline)
		return
	
	show_next_line()


func show_next_line():
	if timeline_index >= timeline_dialogue.size():
		print("End of timeline: ", current_timeline)
		self.visible = false  # Hide the entire UI when dialogue ends
		return

	var entry = timeline_dialogue[timeline_index]
	timeline_index += 1
	
	# Change character sprite if 'sprite' key exists in JSON
	if entry.has("sprite"):
		set_character_sprite(entry.sprite)
	
	# Check for choices
	if entry.has("choices"):
		show_choices(entry.choices)
		return

	name_label.text = entry.get("speaker", "")
	full_text = entry.get("text", "")
	dialogue_label.text = ""
	char_index = 0
	is_typing = true
	type_next_character()


func set_character_sprite(sprite_path: String) -> void:
	# Load the texture and set it
	var tex = load(sprite_path)
	if tex is Texture2D:
		character_sprite.texture = tex
	else:
		push_error("Failed to load texture: " + sprite_path)


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
			show_next_line()


func show_choices(choices: Array):
	is_typing = false
	dialogue_label.text = ""
	choice_box.visible = true
	queue_free_children()

	for choice in choices:
		var button = Button.new()
		button.text = choice.text
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(func():
			choice_box.visible = false
			load_timeline(choice.next_timeline)
		)
		choice_box.add_child(button)


func queue_free_children():
	for child in choice_box.get_children():
		child.queue_free()

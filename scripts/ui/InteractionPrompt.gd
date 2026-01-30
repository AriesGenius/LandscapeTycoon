extends CanvasLayer

@onready var label: Label = $CenterContainer/PanelContainer/MarginContainer/Label

func _ready() -> void:
	add_to_group("interaction_prompt")
	hide()
	print("InteractionPrompt initialized")

func show_prompt(text: String) -> void:
	label.text = text
	show()

func hide_prompt() -> void:
	hide()

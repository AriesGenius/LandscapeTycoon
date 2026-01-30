extends CanvasLayer

var panel: PanelContainer
var is_paused: bool = false

func _ready() -> void:
	layer = 50
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("pause_menu")
	_build_ui()
	hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		if is_paused:
			resume()
		else:
			pause()

func pause() -> void:
	is_paused = true
	get_tree().paused = true
	show()

func resume() -> void:
	is_paused = false
	get_tree().paused = false
	hide()

func _on_resume_pressed() -> void:
	resume()

func _on_save_pressed() -> void:
	PlayerData.save_game()
	var task_data = TaskManager.save_tasks()
	var file = FileAccess.open("user://save_tasks.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(task_data, "\t"))
		file.close()
	print("Game saved from pause menu")

func _on_quit_pressed() -> void:
	resume()
	GameManager.return_to_city()

func _build_ui() -> void:
	# 半透明遮罩
	var overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.5)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)

	# 中心面板
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(300, 280)
	center.add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 15)
	panel.add_child(vbox)

	# 标题
	var title = Label.new()
	title.text = "游戏暂停"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	vbox.add_child(title)

	# 分隔
	var sep = HSeparator.new()
	vbox.add_child(sep)

	# 继续游戏
	var resume_btn = Button.new()
	resume_btn.text = "继续游戏"
	resume_btn.custom_minimum_size = Vector2(200, 40)
	resume_btn.pressed.connect(_on_resume_pressed)
	vbox.add_child(resume_btn)

	# 保存游戏
	var save_btn = Button.new()
	save_btn.text = "保存游戏"
	save_btn.custom_minimum_size = Vector2(200, 40)
	save_btn.pressed.connect(_on_save_pressed)
	vbox.add_child(save_btn)

	# 返回城市
	var quit_btn = Button.new()
	quit_btn.text = "返回城市"
	quit_btn.custom_minimum_size = Vector2(200, 40)
	quit_btn.pressed.connect(_on_quit_pressed)
	vbox.add_child(quit_btn)

extends CanvasLayer

# 全局通知系统：飘字、提示条

var toast_container: VBoxContainer
var float_container: Control

func _ready() -> void:
	layer = 80
	add_to_group("notification")

	# 右上角提示条容器
	toast_container = VBoxContainer.new()
	toast_container.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	toast_container.position = Vector2(-320, 10)
	toast_container.size = Vector2(300, 400)
	toast_container.add_theme_constant_override("separation", 5)
	add_child(toast_container)

	# 屏幕中央飘字容器
	float_container = Control.new()
	float_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	float_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(float_container)

	# 连接信号
	PlayerData.gold_changed.connect(_on_gold_changed)
	PlayerData.level_up.connect(_on_level_up)
	PlayerData.reputation_changed.connect(_on_reputation_changed)

var _last_gold: int = -1

func _on_gold_changed(new_amount: int) -> void:
	if _last_gold < 0:
		_last_gold = new_amount
		return
	var diff = new_amount - _last_gold
	_last_gold = new_amount
	if diff > 0:
		show_float_text("+%d 金币" % diff, Color.GOLD)
	elif diff < 0:
		show_float_text("-%d 金币" % absi(diff), Color.INDIAN_RED)

func _on_level_up(new_level: int, points: int) -> void:
	show_toast("升级! 等级 %d - 获得 %d 属性点" % [new_level, points], Color.GOLD, 4.0)
	show_float_text("LEVEL UP!", Color.GOLD)

func _on_reputation_changed(new_rep: int) -> void:
	var tier = PlayerData.get_reputation_tier()
	# 只在升阶时提示
	if new_rep == 100 or new_rep == 300 or new_rep == 600 or new_rep == 1000:
		show_toast("声望提升至: " + tier, Color.MEDIUM_PURPLE, 3.0)

# 显示右上角提示条
func show_toast(text: String, color: Color = Color.WHITE, duration: float = 3.0) -> void:
	var panel = PanelContainer.new()

	var lbl = Label.new()
	lbl.text = text
	lbl.add_theme_color_override("font_color", color)
	lbl.add_theme_font_size_override("font_size", 16)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(lbl)

	toast_container.add_child(panel)

	# 淡出并移除
	var tween = create_tween()
	tween.tween_interval(duration)
	tween.tween_property(panel, "modulate:a", 0.0, 0.5)
	tween.tween_callback(panel.queue_free)

# 显示屏幕中央飘字
func show_float_text(text: String, color: Color = Color.WHITE) -> void:
	var lbl = Label.new()
	lbl.text = text
	lbl.add_theme_color_override("font_color", color)
	lbl.add_theme_font_size_override("font_size", 22)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.position = Vector2(540, 300)
	lbl.size = Vector2(200, 40)
	float_container.add_child(lbl)

	lbl.pivot_offset = Vector2(100, 20)
	lbl.scale = Vector2(0.3, 0.3)

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(lbl, "scale", Vector2(1.0, 1.0), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(lbl, "position:y", 220.0, 1.2).set_ease(Tween.EASE_OUT)
	tween.tween_property(lbl, "modulate:a", 0.0, 1.2).set_delay(0.3)
	tween.chain().tween_callback(lbl.queue_free)

# 显示任务接取提示
func show_task_accepted(task_name: String, client_name: String = "") -> void:
	show_toast("任务已接取: " + task_name, Color.CYAN, 4.0)
	if client_name != "":
		show_toast("前往 " + client_name + " 家开始工作!", Color.WHITE, 4.0)
	else:
		show_toast("前往客户家开始工作!", Color.WHITE, 4.0)

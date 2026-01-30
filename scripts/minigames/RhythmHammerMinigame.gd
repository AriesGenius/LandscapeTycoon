extends CanvasLayer

# 节奏打桩小游戏
# 在指示器到达目标区域时按E键打击，连续成功得高分

signal minigame_completed(score: float)

var is_active: bool = false
var dexterity_bonus: float = 0.0

# 节奏设置
var total_beats: int = 8
var current_beat: int = 0
var hits: int = 0
var misses: int = 0

# 指示器
var indicator_pos: float = 0.0  # 0.0 到 1.0
var indicator_speed: float = 1.2
var indicator_direction: float = 1.0

# 目标区域
var target_center: float = 0.5
var target_width: float = 0.15  # 受灵巧加成
var can_hit: bool = true  # 防止同一拍重复按键

# 状态
var beat_active: bool = false
var beat_pause_timer: float = 0.0
const BEAT_PAUSE: float = 0.3

# UI
var bg_bar: ColorRect
var target_rect: ColorRect
var indicator_rect: ColorRect
var score_label: Label
var beat_label: Label
var hint_label: Label
var result_labels: Array = []

func _ready() -> void:
	dexterity_bonus = PlayerData.dexterity * 0.02
	target_width += dexterity_bonus * 0.3  # 灵巧扩大判定
	layer = 100
	_build_ui()
	hide()

func start_minigame() -> void:
	is_active = true
	current_beat = 0
	hits = 0
	misses = 0
	indicator_pos = 0.0
	indicator_direction = 1.0
	can_hit = true
	beat_active = true
	beat_pause_timer = 0.0
	_new_beat()

	# 清除之前的结果标记
	for l in result_labels:
		l.queue_free()
	result_labels.clear()

	show()

func _process(delta: float) -> void:
	if not is_active:
		return

	if not beat_active:
		beat_pause_timer -= delta
		if beat_pause_timer <= 0:
			beat_active = true
			can_hit = true
			_new_beat()
		_update_ui()
		return

	# 移动指示器
	indicator_pos += indicator_direction * indicator_speed * delta
	if indicator_pos >= 1.0:
		indicator_pos = 1.0
		indicator_direction = -1.0
	elif indicator_pos <= 0.0:
		indicator_pos = 0.0
		indicator_direction = 1.0

	# 按E打击
	if Input.is_action_just_pressed("interact") and can_hit:
		can_hit = false
		var dist = absf(indicator_pos - target_center)
		if dist <= target_width / 2.0:
			hits += 1
			_show_beat_result(true)
		else:
			misses += 1
			_show_beat_result(false)
		_advance_beat()

	# 指示器走完一个来回没按就算miss
	if indicator_direction == -1.0 and indicator_pos <= 0.05 and can_hit:
		can_hit = false
		misses += 1
		_show_beat_result(false)
		_advance_beat()

	_update_ui()

func _advance_beat() -> void:
	current_beat += 1
	if current_beat >= total_beats:
		var score = float(hits) / float(total_beats)
		end_minigame(score)
		return
	beat_active = false
	beat_pause_timer = BEAT_PAUSE

func _new_beat() -> void:
	# 随机新目标位置
	target_center = randf_range(0.25, 0.75)
	indicator_pos = 0.0
	indicator_direction = 1.0
	# 逐渐加速
	indicator_speed = 1.2 + current_beat * 0.1

func end_minigame(score: float) -> void:
	is_active = false
	hide()
	minigame_completed.emit(clampf(score, 0.0, 1.0))

func _show_beat_result(success: bool) -> void:
	var lbl = Label.new()
	lbl.text = "HIT!" if success else "MISS"
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_color_override("font_color", Color.GREEN if success else Color.RED)
	lbl.position = Vector2(590, 250)
	lbl.size = Vector2(100, 30)
	add_child(lbl)
	result_labels.append(lbl)
	# 自动消失
	get_tree().create_timer(0.5).timeout.connect(func():
		if is_instance_valid(lbl):
			lbl.queue_free()
			result_labels.erase(lbl)
	)

func _build_ui() -> void:
	# 遮罩
	var overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.6)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)

	# 标题
	hint_label = Label.new()
	hint_label.text = "节奏打桩 - 指示器到达绿色区域时按E!"
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	hint_label.position = Vector2(-200, 80)
	hint_label.size = Vector2(400, 30)
	add_child(hint_label)

	# 打击条背景
	bg_bar = ColorRect.new()
	bg_bar.color = Color(0.2, 0.2, 0.3, 0.9)
	bg_bar.size = Vector2(500, 40)
	bg_bar.position = Vector2(390, 340)
	add_child(bg_bar)

	# 目标区域
	target_rect = ColorRect.new()
	target_rect.color = Color(0, 0.7, 0, 0.5)
	target_rect.size = Vector2(target_width * 500, 40)
	add_child(target_rect)

	# 指示器
	indicator_rect = ColorRect.new()
	indicator_rect.color = Color(1, 0.2, 0.2, 0.9)
	indicator_rect.size = Vector2(8, 50)
	add_child(indicator_rect)

	# 得分
	score_label = Label.new()
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_label.position = Vector2(490, 400)
	score_label.size = Vector2(300, 30)
	add_child(score_label)

	# 节拍计数
	beat_label = Label.new()
	beat_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	beat_label.position = Vector2(490, 430)
	beat_label.size = Vector2(300, 30)
	add_child(beat_label)

func _update_ui() -> void:
	# 指示器位置
	indicator_rect.position = Vector2(390 + indicator_pos * 500 - 4, 335)

	# 目标区域位置
	var tw = target_width * 500
	target_rect.size = Vector2(tw, 40)
	target_rect.position = Vector2(390 + target_center * 500 - tw / 2, 340)

	# 文字
	score_label.text = "命中: %d / %d" % [hits, current_beat]
	beat_label.text = "第 %d / %d 拍" % [current_beat + 1, total_beats]

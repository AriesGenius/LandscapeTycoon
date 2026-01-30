extends CanvasLayer

# 水平仪对齐小游戏
# 玩家用左右方向键让气泡停在中心位置

signal minigame_completed(score: float)

var is_active: bool = false
var dexterity_bonus: float = 0.0

# 气泡位置 (-1.0 到 1.0, 0为中心)
var bubble_pos: float = 0.0
var bubble_velocity: float = 0.0
var bubble_drift_speed: float = 1.5  # 自然漂移速度
var bubble_control_speed: float = 3.0  # 玩家控制速度

# 判定
var align_threshold: float = 0.15  # 对齐判定范围(受灵巧加成)
var hold_time_needed: float = 1.5  # 需要保持对齐的时间
var hold_timer: float = 0.0
var time_limit: float = 8.0
var elapsed: float = 0.0

# 漂移变化
var drift_direction: float = 1.0
var drift_change_timer: float = 0.0

# UI节点
var bg_rect: ColorRect
var bubble_rect: ColorRect
var center_line: ColorRect
var threshold_left: ColorRect
var threshold_right: ColorRect
var hold_bar: ProgressBar
var timer_label: Label
var hint_label: Label

func _ready() -> void:
	dexterity_bonus = PlayerData.dexterity * 0.02
	align_threshold += dexterity_bonus * 0.5  # 灵巧扩大判定
	layer = 100
	_build_ui()
	hide()

func start_minigame() -> void:
	is_active = true
	bubble_pos = randf_range(-0.5, 0.5)
	bubble_velocity = 0.0
	hold_timer = 0.0
	elapsed = 0.0
	drift_direction = [-1.0, 1.0][randi() % 2]
	drift_change_timer = randf_range(0.8, 2.0)
	show()

func _process(delta: float) -> void:
	if not is_active:
		return

	elapsed += delta

	# 时间到
	if elapsed >= time_limit:
		var score = hold_timer / hold_time_needed
		end_minigame(score)
		return

	# 随机改变漂移方向
	drift_change_timer -= delta
	if drift_change_timer <= 0:
		drift_direction = -drift_direction
		drift_change_timer = randf_range(0.5, 1.5)

	# 自然漂移
	bubble_velocity += drift_direction * bubble_drift_speed * delta

	# 玩家控制
	if Input.is_action_pressed("move_left"):
		bubble_velocity -= bubble_control_speed * delta
	if Input.is_action_pressed("move_right"):
		bubble_velocity += bubble_control_speed * delta

	# 阻尼
	bubble_velocity *= 0.95

	# 更新位置
	bubble_pos += bubble_velocity * delta
	bubble_pos = clampf(bubble_pos, -1.0, 1.0)

	# 检测对齐
	if absf(bubble_pos) <= align_threshold:
		hold_timer += delta
		if hold_timer >= hold_time_needed:
			end_minigame(1.0)
			return
	else:
		hold_timer = maxf(0.0, hold_timer - delta * 0.5)

	_update_ui()

func end_minigame(score: float) -> void:
	is_active = false
	hide()
	minigame_completed.emit(clampf(score, 0.0, 1.0))

func _build_ui() -> void:
	# 背景遮罩
	var overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.6)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)

	# 标题
	hint_label = Label.new()
	hint_label.text = "水平仪对齐 - 用左右方向键让气泡停在中心！"
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	hint_label.position = Vector2(-200, 80)
	hint_label.size = Vector2(400, 30)
	add_child(hint_label)

	# 水平仪背景条
	bg_rect = ColorRect.new()
	bg_rect.color = Color(0.2, 0.2, 0.3, 0.9)
	bg_rect.size = Vector2(500, 40)
	bg_rect.position = Vector2(390, 320)
	add_child(bg_rect)

	# 中心线
	center_line = ColorRect.new()
	center_line.color = Color(0, 1, 0, 0.8)
	center_line.size = Vector2(2, 40)
	center_line.position = Vector2(640, 320)
	add_child(center_line)

	# 阈值线左
	threshold_left = ColorRect.new()
	threshold_left.color = Color(1, 1, 0, 0.5)
	threshold_left.size = Vector2(2, 40)
	add_child(threshold_left)

	# 阈值线右
	threshold_right = ColorRect.new()
	threshold_right.color = Color(1, 1, 0, 0.5)
	threshold_right.size = Vector2(2, 40)
	add_child(threshold_right)

	# 气泡
	bubble_rect = ColorRect.new()
	bubble_rect.color = Color(0.2, 0.8, 1.0, 0.9)
	bubble_rect.size = Vector2(20, 30)
	add_child(bubble_rect)

	# 保持进度条
	hold_bar = ProgressBar.new()
	hold_bar.size = Vector2(300, 25)
	hold_bar.position = Vector2(490, 390)
	hold_bar.max_value = 100
	hold_bar.value = 0
	add_child(hold_bar)

	# 计时器
	timer_label = Label.new()
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	timer_label.position = Vector2(540, 430)
	timer_label.size = Vector2(200, 30)
	add_child(timer_label)

func _update_ui() -> void:
	# 气泡位置 (中心640, 范围+-250)
	var bubble_x = 640 + bubble_pos * 250 - 10
	bubble_rect.position = Vector2(bubble_x, 325)

	# 颜色反馈
	if absf(bubble_pos) <= align_threshold:
		bubble_rect.color = Color(0, 1, 0, 0.9)  # 绿色=对齐
	else:
		bubble_rect.color = Color(0.2, 0.8, 1.0, 0.9)  # 蓝色=未对齐

	# 阈值线位置
	threshold_left.position = Vector2(640 - align_threshold * 250, 320)
	threshold_right.position = Vector2(640 + align_threshold * 250, 320)

	# 保持进度
	hold_bar.value = (hold_timer / hold_time_needed) * 100

	# 计时
	var remaining = time_limit - elapsed
	timer_label.text = "剩余: %.1f秒" % remaining

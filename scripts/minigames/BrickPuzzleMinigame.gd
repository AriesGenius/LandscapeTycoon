extends CanvasLayer

# 砖块拼图小游戏
# 在网格中快速点击/按键填充砖块，限时完成

signal minigame_completed(score: float)

var is_active: bool = false
var dexterity_bonus: float = 0.0

# 网格设置
var grid_cols: int = 5
var grid_rows: int = 4
var grid: Array = []  # true = 已填充, false = 未填充
var cursor_x: int = 0
var cursor_y: int = 0
var total_cells: int = 0
var filled_cells: int = 0

# 时间
var time_limit: float = 10.0
var elapsed: float = 0.0

# UI
var cells: Array = []  # 存储ColorRect引用
var cursor_rect: ColorRect
var timer_label: Label
var progress_label: Label
var hint_label: Label

func _ready() -> void:
	dexterity_bonus = PlayerData.dexterity * 0.02
	time_limit += dexterity_bonus * 2.0  # 灵巧增加时间
	layer = 100
	_build_ui()
	hide()

func start_minigame() -> void:
	is_active = true
	elapsed = 0.0
	filled_cells = 0
	total_cells = grid_cols * grid_rows
	cursor_x = 0
	cursor_y = 0

	grid.clear()
	for i in range(total_cells):
		grid.append(false)

	_update_grid_ui()
	show()

func _process(delta: float) -> void:
	if not is_active:
		return

	elapsed += delta
	if elapsed >= time_limit:
		var score = float(filled_cells) / float(total_cells)
		end_minigame(score)
		return

	# 方向键移动光标
	if Input.is_action_just_pressed("move_left"):
		cursor_x = maxi(0, cursor_x - 1)
	if Input.is_action_just_pressed("move_right"):
		cursor_x = mini(grid_cols - 1, cursor_x + 1)
	if Input.is_action_just_pressed("move_up"):
		cursor_y = maxi(0, cursor_y - 1)
	if Input.is_action_just_pressed("move_down"):
		cursor_y = mini(grid_rows - 1, cursor_y + 1)

	# 按E/空格放置砖块
	if Input.is_action_just_pressed("interact"):
		var idx = cursor_y * grid_cols + cursor_x
		if not grid[idx]:
			grid[idx] = true
			filled_cells += 1
			if filled_cells >= total_cells:
				end_minigame(1.0)
				return

	_update_grid_ui()

	# 更新UI文字
	var remaining = time_limit - elapsed
	timer_label.text = "剩余: %.1f秒" % remaining
	progress_label.text = "%d/%d 砖块" % [filled_cells, total_cells]

func end_minigame(score: float) -> void:
	is_active = false
	hide()
	minigame_completed.emit(clampf(score, 0.0, 1.0))

func _build_ui() -> void:
	# 遮罩
	var overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.6)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)

	# 标题
	hint_label = Label.new()
	hint_label.text = "砖块铺设 - 方向键移动, E键放置砖块!"
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	hint_label.position = Vector2(-200, 60)
	hint_label.size = Vector2(400, 30)
	add_child(hint_label)

	# 创建网格
	var cell_size = 50
	var gap = 4
	var grid_width = grid_cols * (cell_size + gap)
	var grid_height = grid_rows * (cell_size + gap)
	var start_x = (1280 - grid_width) / 2
	var start_y = (720 - grid_height) / 2

	cells.clear()
	for row in range(grid_rows):
		for col in range(grid_cols):
			var cell = ColorRect.new()
			cell.size = Vector2(cell_size, cell_size)
			cell.position = Vector2(
				start_x + col * (cell_size + gap),
				start_y + row * (cell_size + gap)
			)
			cell.color = Color(0.3, 0.3, 0.3, 0.8)
			add_child(cell)
			cells.append(cell)

	# 光标
	cursor_rect = ColorRect.new()
	cursor_rect.size = Vector2(cell_size + 4, cell_size + 4)
	cursor_rect.color = Color(1, 1, 0, 0.6)
	add_child(cursor_rect)

	# 进度标签
	progress_label = Label.new()
	progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	progress_label.position = Vector2(490, start_y + grid_height + 20)
	progress_label.size = Vector2(300, 30)
	add_child(progress_label)

	# 计时器
	timer_label = Label.new()
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	timer_label.position = Vector2(490, start_y + grid_height + 50)
	timer_label.size = Vector2(300, 30)
	add_child(timer_label)

func _update_grid_ui() -> void:
	var cell_size = 50
	var gap = 4
	var grid_width = grid_cols * (cell_size + gap)
	var grid_height = grid_rows * (cell_size + gap)
	var start_x = (1280 - grid_width) / 2
	var start_y = (720 - grid_height) / 2

	for i in range(cells.size()):
		if grid.size() > i and grid[i]:
			cells[i].color = Color(0.8, 0.4, 0.2, 1.0)  # 砖色
		else:
			cells[i].color = Color(0.3, 0.3, 0.3, 0.8)  # 空

	# 更新光标位置
	cursor_rect.position = Vector2(
		start_x + cursor_x * (cell_size + gap) - 2,
		start_y + cursor_y * (cell_size + gap) - 2
	)

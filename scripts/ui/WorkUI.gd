extends CanvasLayer

@onready var task_name_label: Label = $Panel/MarginContainer/VBoxContainer/TaskNameLabel
@onready var progress_label: Label = $Panel/MarginContainer/VBoxContainer/ProgressLabel
@onready var timer_label: Label = $Panel/MarginContainer/VBoxContainer/TimerLabel
@onready var quality_label: Label = $Panel/MarginContainer/VBoxContainer/QualityLabel

var work_site: Node2D = null

func _ready() -> void:
	# 获取父节点（WorkSite）
	work_site = get_parent()
	
	if TaskManager.active_task.is_empty():
		print("WorkUI: No active task")
		return
	
	task_name_label.text = "任务: " + TaskManager.active_task.full_name
	print("WorkUI initialized")

func _process(delta: float) -> void:
	if work_site:
		_update_timer()
		

func _update_timer() -> void:
	var remaining = work_site.get_time_remaining()
	var minutes = int(remaining / 60)
	var seconds = int(remaining) % 60
	
	timer_label.text = "剩余时间: %d:%02d" % [minutes, seconds]
	
	# 时间不足警告
	if remaining < 30:
		timer_label.add_theme_color_override("font_color", Color.RED)
	else:
		timer_label.add_theme_color_override("font_color", Color.WHITE)

func update_progress(completed: int, total: int) -> void:
	progress_label.text = "%d/%d 区域完成" % [completed, total]
	var quality = (float(completed) / float(total)) * 100
	quality_label.text = "完成度: %.0f%%" % quality

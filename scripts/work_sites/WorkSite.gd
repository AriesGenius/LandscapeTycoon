extends Node2D

var work_areas_total: int = 0
var work_areas_completed: int = 0
var start_time: float = 0.0
var task_time_limit: float = 0.0

@onready var work_areas_container: Node2D = $WorkAreas
@onready var work_ui: CanvasLayer = $WorkUI
@onready var result_panel: CanvasLayer = $TaskResultPanel

func _ready() -> void:
	if TaskManager.active_task.is_empty():
		print("错误：没有活动任务！")
		GameManager.return_to_city()
		return
	
	start_time = Time.get_ticks_msec() / 1000.0
	task_time_limit = TaskManager.active_task.time_limit
	
	_setup_work_areas()
	
	print("WorkSite ready. Task: ", TaskManager.active_task.full_name)
	print("Time limit: ", task_time_limit, " seconds")
	print("Work areas: ", work_areas_total)

func _setup_work_areas() -> void:
	work_areas_total = work_areas_container.get_child_count()
	
	if work_areas_total == 0:
		print("警告：没有工作区域！生成默认工作区域")
		_generate_default_work_areas()
		work_areas_total = work_areas_container.get_child_count()
	
	# 连接所有工作区域的完成信号
	var areas = work_areas_container.get_children()
	var base_work_type = TaskManager.active_task.work_type

	for i in range(areas.size()):
		var area = areas[i]
		if area.has_signal("work_completed"):
			area.work_completed.connect(_on_work_area_completed)
			if area.has_method("set_work_type"):
				# 非 dexterity 任务中，随机让一个工作区域变成小游戏（精细操作步骤）
				if base_work_type != "dexterity" and i == areas.size() - 1 and areas.size() >= 3:
					area.set_work_type("dexterity")
					print("Work area ", i, " set to dexterity (minigame)")
				else:
					area.set_work_type(base_work_type)

func _generate_default_work_areas() -> void:
	# 根据任务生成默认工作区域
	var work_area_count = TaskManager.active_task.get("work_areas", 3)
	
	# 检查场景是否存在
	if not ResourceLoader.exists("res://scenes/work_sites/work_area.tscn"):
		push_warning("WorkArea.tscn 场景未创建，无法生成工作区域")
		return
	
	var WorkAreaScene = load("res://scenes/work_sites/work_area.tscn")
	
	for i in range(work_area_count):
		var work_area = WorkAreaScene.instantiate()
		work_areas_container.add_child(work_area)
		
		# 随机位置分布
		var angle = (i / float(work_area_count)) * TAU
		var radius = 200
		work_area.position = Vector2(
			cos(angle) * radius,
			sin(angle) * radius
		)

func _on_work_area_completed() -> void:
	work_areas_completed += 1
	print("Work area completed: ", work_areas_completed, "/", work_areas_total)
	
	# 更新UI
	if work_ui and work_ui.has_method("update_progress"):
		work_ui.update_progress(work_areas_completed, work_areas_total)
	
	# 检查是否全部完成
	if work_areas_completed >= work_areas_total:
		_complete_task()

func _complete_task() -> void:
	var time_taken = (Time.get_ticks_msec() / 1000.0) - start_time
	var quality_score = get_progress()  # 基于实际完成区域比例
	
	print("Task completed!")
	print("Time taken: ", time_taken, " seconds")
	
	# 通过 TaskManager 完成任务
	var result = TaskManager.complete_task(time_taken, quality_score)
	
	# 显示结果面板
	if result_panel:
		result_panel.show_result(result)
	else:
		print("结果面板未找到，直接返回城市")
		await get_tree().create_timer(2.0).timeout
		GameManager.return_to_city()

func get_progress() -> float:
	if work_areas_total == 0:
		return 0.0
	return float(work_areas_completed) / float(work_areas_total)

func get_time_elapsed() -> float:
	return (Time.get_ticks_msec() / 1000.0) - start_time

func _process(delta: float) -> void:
	if work_areas_completed < work_areas_total and get_time_remaining() <= 0.0:
		print("Time's up! Force completing task.")
		_complete_task()

func get_time_remaining() -> float:
	return max(0.0, task_time_limit - get_time_elapsed())

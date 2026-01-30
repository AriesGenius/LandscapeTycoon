extends CanvasLayer

# 这些变量会在场景创建后自动获取
# 如果节点不存在，变量会是 null，不会报错
var panel: Panel
var task_list: VBoxContainer
var close_button: Button
var title_label: Label

# 任务项场景 - 注意文件名大小写
var TaskItemScene = null

func _ready() -> void:
	add_to_group("task_panel")
	
	# 尝试加载 TaskItem 场景（支持多种可能的路径）
	var possible_paths = [
		"res://scenes/ui/task_item.tscn",
	]
	
	for path in possible_paths:
		if ResourceLoader.exists(path):
			TaskItemScene = load(path)
			print("TaskPanel: Loaded TaskItem from: ", path)
			break
	
	if TaskItemScene == null:
		print("TaskPanel ERROR: Could not find TaskItem.tscn!")
	
	# 安全地获取节点
	panel = get_node_or_null("CenterContainer/Panel")
	if panel:
		task_list = panel.get_node_or_null("MarginContainer/VBoxContainer/ScrollContainer/TaskList")
		close_button = panel.get_node_or_null("MarginContainer/VBoxContainer/CloseButton")
		title_label = panel.get_node_or_null("MarginContainer/VBoxContainer/TitleLabel")
		
		if close_button:
			close_button.pressed.connect(_on_close_pressed)
	
	hide()
	print("TaskPanel initialized")

func show_panel() -> void:
	show()
	await _populate_tasks()
	print("TaskPanel opened")

func _populate_tasks() -> void:
	print("=== _populate_tasks called ===")
	print("task_list is null? ", task_list == null)
	print("TaskItemScene is null? ", TaskItemScene == null)
	
	# 检查 task_list 是否存在
	if task_list == null:
		print("ERROR: task_list is null!")
		return
	
	# 清空现有任务项
	for child in task_list.get_children():
		child.queue_free()
	
	# 等待一帧确保子节点被清除
	await get_tree().process_frame
	
	print("Populating tasks, available: ", TaskManager.available_tasks.size())
	
	# 添加任务项
	if TaskManager.available_tasks.is_empty():
		var no_tasks_label = Label.new()
		no_tasks_label.text = "暂无可接取的任务"
		no_tasks_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		task_list.add_child(no_tasks_label)
		return
	
	var added_count = 0
	for task in TaskManager.available_tasks:
		# 检查任务是否可接取
		if not TaskManager.is_task_available(task):
			print("Task not available: ", task.get("full_name", "unknown"))
			continue
		
		print("Adding task: ", task.get("full_name", "unknown"))
		
		# 如果 TaskItemScene 存在，使用它；否则创建临时显示
		if TaskItemScene != null:
			var task_item = TaskItemScene.instantiate()
			task_list.add_child(task_item)
			task_item.set_task_data(task)
			task_item.task_accepted.connect(_on_task_accepted)
		else:
			# 备用方案：创建简单的任务显示
			print("Using fallback task display")
			var task_container = VBoxContainer.new()
			
			var name_label = Label.new()
			name_label.text = task.get("full_name", "未知任务")
			task_container.add_child(name_label)
			
			var info_label = Label.new()
			info_label.text = "报酬: " + str(task.get("base_reward", 0)) + "金 | 材料费: " + str(task.get("material_cost", 0)) + "金"
			task_container.add_child(info_label)
			
			var accept_btn = Button.new()
			accept_btn.text = "接取任务"
			accept_btn.pressed.connect(_on_fallback_accept.bind(task))
			task_container.add_child(accept_btn)
			
			var separator = HSeparator.new()
			task_container.add_child(separator)
			
			task_list.add_child(task_container)
		
		added_count += 1
	
	print("Tasks added: ", added_count)

func _on_fallback_accept(task: Dictionary) -> void:
	_on_task_accepted(task)

func _on_task_accepted(task: Dictionary) -> void:
	print("Task accepted from panel: ", task.full_name)
	TaskManager.accept_task(task)
	hide()
	
	# 显示提示
	print("任务已接取！前往", task.client_name, "家开始工作")

func _on_close_pressed() -> void:
	hide()
	print("TaskPanel closed")

extends PanelContainer

signal task_accepted(task: Dictionary)

var task_data: Dictionary

@onready var task_name_label: Label = $MarginContainer/VBoxContainer/TaskNameLabel
@onready var client_label: Label = $MarginContainer/VBoxContainer/ClientLabel
@onready var info_container: HBoxContainer = $MarginContainer/VBoxContainer/InfoContainer
@onready var reward_label: Label = $MarginContainer/VBoxContainer/InfoContainer/RewardLabel
@onready var difficulty_label: Label = $MarginContainer/VBoxContainer/InfoContainer/DifficultyLabel
@onready var time_label: Label = $MarginContainer/VBoxContainer/InfoContainer/TimeLabel
@onready var material_label: Label = $MarginContainer/VBoxContainer/MaterialLabel
@onready var accept_button: Button = $MarginContainer/VBoxContainer/AcceptButton

func _ready() -> void:
	accept_button.pressed.connect(_on_accept_pressed)

func set_task_data(task: Dictionary) -> void:
	task_data = task

	# 设置标签内容
	var source_tag = TaskManager.get_source_label(task.get("source", "platform"))
	task_name_label.text = "[" + source_tag + "] " + task.name

	client_label.text = "客户: " + task.client_name
	reward_label.text = "💰 " + str(task.base_reward) + "金"

	# 难度星级
	var stars = ""
	for i in range(task.difficulty):
		stars += "⭐"
	difficulty_label.text = stars

	# 时间限制
	var minutes = task.time_limit / 60
	time_label.text = "⏱️ " + str(minutes) + "分钟"

	# 材料费用
	var cost = task.get("actual_material_cost", task.material_cost)
	var discount = task.get("material_discount", 0.0)
	if discount > 0:
		material_label.text = "材料费: " + str(cost) + "金 (折扣" + str(int(discount * 100)) + "%)"
	else:
		material_label.text = "材料费: " + str(cost) + "金"

	# 检查是否有足够金币
	if PlayerData.gold < cost:
		accept_button.disabled = true
		accept_button.text = "金币不足"
	else:
		accept_button.disabled = false
		accept_button.text = "接取任务"

	# 检查声望要求
	if task.required_reputation > PlayerData.reputation:
		accept_button.disabled = true
		accept_button.text = "声望不足 (需要" + str(task.required_reputation) + ")"

func _on_accept_pressed() -> void:
	task_accepted.emit(task_data)
	print("TaskItem: Task accepted - ", task_data.full_name)

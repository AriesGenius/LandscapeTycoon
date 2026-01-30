extends Node

# 任务列表
var available_tasks: Array[Dictionary] = []
var active_task: Dictionary = {}
var completed_task_ids: Array[String] = []

# 任务模板
const TASK_TEMPLATES = {
	"trash_cleanup": {
		"name": "清理垃圾",
		"type": "trash",
		"work_type": "agility",
		"base_reward": 150,
		"material_cost": 10,
		"time_limit": 180,
		"difficulty": 1,
		"required_reputation": 0,
		"work_areas": 3
	},
	"lawn_mowing": {
		"name": "修剪草坪",
		"type": "lawn",
		"work_type": "agility",
		"base_reward": 200,
		"material_cost": 50,
		"time_limit": 300,
		"difficulty": 2,
		"required_reputation": 0,
		"work_areas": 4
	},
	"plant_flowers": {
		"name": "种植花卉",
		"type": "plant",
		"work_type": "strength",
		"base_reward": 300,
		"material_cost": 100,
		"time_limit": 360,
		"difficulty": 2,
		"required_reputation": 100,
		"work_areas": 5
	},
	"lay_bricks": {
		"name": "铺设砖面",
		"type": "brick",
		"work_type": "dexterity",
		"base_reward": 500,
		"material_cost": 200,
		"time_limit": 480,
		"difficulty": 3,
		"required_reputation": 0,
		"work_areas": 6
	},
	"build_fence": {
		"name": "建造围栏",
		"type": "fence",
		"work_type": "strength",
		"base_reward": 400,
		"material_cost": 150,
		"time_limit": 420,
		"difficulty": 3,
		"required_reputation": 300,
		"work_areas": 5
	}
}

# 客户名单（与城市地图中的建筑名称对应）
const CLIENT_NAMES = ["A", "B", "C", "D", "E"]

# 任务来源标签
const SOURCE_LABELS = {
	"platform": "平台任务",
	"supplier": "供货商委托",
	"referral": "客户推广"
}

func _ready() -> void:
	print("TaskManager initialized")
	generate_tasks()

# 生成随机任务
func generate_tasks(count: int = 3) -> void:
	available_tasks.clear()

	var task_types = TASK_TEMPLATES.keys()
	var attempts = 0
	var max_attempts = count * 3

	while available_tasks.size() < count and attempts < max_attempts:
		attempts += 1
		var task_type = task_types[randi() % task_types.size()]
		var template = TASK_TEMPLATES[task_type].duplicate()

		# 检查声望要求
		if template.required_reputation > PlayerData.reputation:
			continue

		# 添加客户信息
		var client_name = CLIENT_NAMES[randi() % CLIENT_NAMES.size()]
		template["client_name"] = "客户" + client_name
		template["full_name"] = template.name + " - 客户" + client_name + "家"
		template["id"] = task_type + "_" + str(Time.get_ticks_msec()) + "_" + str(randi())
		template["source"] = "platform"

		# 随机调整报酬 (±20%)
		var variance = randf_range(0.8, 1.2)
		template["base_reward"] = int(template.base_reward * variance)

		# 材料相关默认值
		template["material_quality_bonus"] = 0.0
		template["material_name"] = "基础材料"
		template["actual_material_cost"] = template.material_cost
		template["material_discount"] = 0.0

		available_tasks.append(template)

	# Phase 5: 供货商委托任务
	if PlayerData.reputation >= 100:
		_try_generate_supplier_task()

	# Phase 5: 客户推广任务
	if PlayerData.get_last_rating() >= 4:
		_try_generate_referral_task()

	print("Generated ", available_tasks.size(), " tasks")

func _try_generate_supplier_task() -> void:
	# 声望>=100解锁，材料折扣10-40%
	if randf() > 0.4:
		return

	var task_types = TASK_TEMPLATES.keys()
	var task_type = task_types[randi() % task_types.size()]
	var template = TASK_TEMPLATES[task_type].duplicate()

	if template.required_reputation > PlayerData.reputation:
		return

	var client_name = CLIENT_NAMES[randi() % CLIENT_NAMES.size()]
	template["client_name"] = "客户" + client_name
	template["full_name"] = template.name + " - 客户" + client_name + "家"
	template["id"] = task_type + "_supplier_" + str(Time.get_ticks_msec())
	template["source"] = "supplier"

	var discount = randf_range(0.1, 0.4)
	template["material_discount"] = discount
	template["material_cost"] = int(template.material_cost * (1.0 - discount))
	template["material_quality_bonus"] = 0.0
	template["material_name"] = "基础材料"
	template["actual_material_cost"] = template.material_cost

	var variance = randf_range(0.8, 1.2)
	template["base_reward"] = int(template.base_reward * variance)

	available_tasks.append(template)
	print("Generated supplier task with ", int(discount * 100), "% material discount")

func _try_generate_referral_task() -> void:
	# 上次评分>=4星时概率触发邻居任务
	if randf() > 0.5:
		return

	var task_types = TASK_TEMPLATES.keys()
	var task_type = task_types[randi() % task_types.size()]
	var template = TASK_TEMPLATES[task_type].duplicate()

	if template.required_reputation > PlayerData.reputation:
		return

	var client_name = CLIENT_NAMES[randi() % CLIENT_NAMES.size()]
	template["client_name"] = "客户" + client_name
	template["full_name"] = template.name + " - 客户" + client_name + "家 (邻居推荐)"
	template["id"] = task_type + "_referral_" + str(Time.get_ticks_msec())
	template["source"] = "referral"

	# 推荐任务报酬稍高
	var variance = randf_range(1.0, 1.3)
	template["base_reward"] = int(template.base_reward * variance)

	template["material_quality_bonus"] = 0.0
	template["material_name"] = "基础材料"
	template["actual_material_cost"] = template.material_cost
	template["material_discount"] = 0.0

	available_tasks.append(template)
	print("Generated referral task from satisfied customer")

# 接取任务
func accept_task(task: Dictionary) -> void:
	if task.is_empty():
		print("Cannot accept empty task!")
		return

	var cost = task.get("actual_material_cost", task.material_cost)

	# 检查是否有足够金币购买材料
	if PlayerData.gold < cost:
		print("Not enough gold for materials! Need: ", cost)
		return

	# 扣除材料费用
	PlayerData.spend_gold(cost)

	active_task = task.duplicate()
	print("Task accepted: ", active_task.full_name)
	print("Materials purchased: -", cost, " gold")

	# 显示通知
	if is_instance_valid(NotificationSystem):
		NotificationSystem.show_task_accepted(active_task.full_name, active_task.client_name)

# 完成任务
func complete_task(time_taken: float, quality_score: float) -> Dictionary:
	if active_task.is_empty():
		print("No active task to complete!")
		return {}

	# 加入材料质量加成
	var material_bonus = active_task.get("material_quality_bonus", 0.0)
	var adjusted_quality = min(1.0, quality_score + material_bonus)

	# 计算评分
	var rating = _calculate_rating(time_taken, adjusted_quality)

	# 计算报酬
	var reward = _calculate_reward(rating)

	# 计算声望
	var reputation_gain = _calculate_reputation(rating)

	# 更新玩家数据
	PlayerData.add_gold(reward)
	PlayerData.add_reputation(reputation_gain)
	PlayerData.add_experience(50 * rating)
	PlayerData.record_task_completion(rating)

	# 记录完成
	completed_task_ids.append(active_task.id)

	var result = {
		"task_name": active_task.full_name,
		"rating": rating,
		"reward": reward,
		"reputation": reputation_gain,
		"experience": 50 * rating,
		"material_name": active_task.get("material_name", "基础材料"),
	}

	print("Task completed! Rating: ", rating, "★")

	# 清空活动任务
	active_task = {}

	# 重新生成任务
	generate_tasks(3)

	return result

# 计算任务评分 (1-5星)
func _calculate_rating(time_taken: float, quality_score: float) -> int:
	var time_limit = active_task.time_limit
	var time_ratio = time_taken / time_limit

	# 时间评分 (40%)
	var time_score = 0.0
	if time_ratio <= 0.5:
		time_score = 1.0
	elif time_ratio <= 0.75:
		time_score = 0.8
	elif time_ratio <= 1.0:
		time_score = 0.6
	elif time_ratio <= 1.5:
		time_score = 0.4
	else:
		time_score = 0.2

	# 质量评分 (60%)
	var quality_ratio = quality_score

	# 综合评分
	var total_score = time_score * 0.4 + quality_ratio * 0.6

	# 转换为星级
	if total_score >= 0.9:
		return 5
	elif total_score >= 0.75:
		return 4
	elif total_score >= 0.6:
		return 3
	elif total_score >= 0.4:
		return 2
	else:
		return 1

# 计算报酬
func _calculate_reward(rating: int) -> int:
	var base_reward = active_task.base_reward
	var multipliers = [0.5, 0.8, 1.0, 1.2, 1.5]
	return int(base_reward * multipliers[rating - 1])

# 计算声望增长
func _calculate_reputation(rating: int) -> int:
	return rating * 5

# 检查任务是否可用
func is_task_available(task: Dictionary) -> bool:
	return task.required_reputation <= PlayerData.reputation

# 获取可用任务数量
func get_available_task_count() -> int:
	var count = 0
	for task in available_tasks:
		if is_task_available(task):
			count += 1
	return count

# 获取来源标签
func get_source_label(source: String) -> String:
	return SOURCE_LABELS.get(source, "平台任务")

# 保存任务状态
func save_tasks() -> Dictionary:
	return {
		"available_tasks": available_tasks,
		"active_task": active_task,
		"completed_task_ids": completed_task_ids,
	}

func load_tasks(data: Dictionary) -> void:
	if data.has("available_tasks"):
		available_tasks.clear()
		for t in data.available_tasks:
			available_tasks.append(t)
	if data.has("active_task"):
		active_task = data.active_task
	if data.has("completed_task_ids"):
		completed_task_ids.clear()
		for id in data.completed_task_ids:
			completed_task_ids.append(id)
	print("Tasks loaded: ", available_tasks.size(), " available")

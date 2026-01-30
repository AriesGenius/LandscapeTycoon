extends Node

# 基础信息
var player_name: String = "Alex"
var company_name: String = "GreenScape"

# 经济
var gold: int = 500
var experience: int = 0
var level: int = 1
var attribute_points: int = 0  # 可分配的属性点

# 属性
var strength: int = 10      # 力量：影响手动工作（挖坑、铲土、除草）
var agility: int = 10       # 敏捷：影响移动、电动工具、清理垃圾
var dexterity: int = 10     # 灵巧：影响小游戏容错率和反应时间
var reputation: int = 0     # 声望：解锁高级任务和材料

# 工具装备
var equipped_tools: Dictionary = {
	"shovel": {"name": "普通铲子", "efficiency": 1.0},
	"mower": {"name": "手动推剪", "efficiency": 1.0},
	"broom": {"name": "塑料扫帚", "efficiency": 1.0},
	"hammer": {"name": "木柄锤", "efficiency": 1.0},
	"level": {"name": "传统水平仪", "efficiency": 1.0, "accuracy": 0}
}

# 已购买的工具（防止重复购买）
var owned_tools: Array[Dictionary] = []

# 统计
var completed_tasks: int = 0
var total_earnings: int = 0
var five_star_tasks: int = 0
var total_rating: float = 0.0

# 最近评分历史（Phase 5）
var recent_ratings: Array[int] = []
const MAX_RATING_HISTORY: int = 20

# 信号
signal gold_changed(new_amount: int)
signal attribute_changed()
signal level_up(new_level: int, points: int)
signal reputation_changed(new_reputation: int)

func _ready() -> void:
	print("PlayerData initialized")
	print("Starting gold: ", gold)

# 金币管理
func add_gold(amount: int) -> void:
	gold += amount
	total_earnings += amount
	gold_changed.emit(gold)
	print("Gold added: +", amount, " | Total: ", gold)

func spend_gold(amount: int) -> bool:
	if gold >= amount:
		gold -= amount
		gold_changed.emit(gold)
		print("Gold spent: -", amount, " | Remaining: ", gold)
		return true
	else:
		print("Not enough gold! Need: ", amount, " | Have: ", gold)
		return false

# 经验和升级
func add_experience(amount: int) -> void:
	experience += amount
	print("Experience gained: +", amount, " | Total: ", experience)
	_check_level_up()

func _check_level_up() -> void:
	var exp_needed = level * 500  # 每级需要的经验
	while experience >= exp_needed:
		level += 1
		experience -= exp_needed
		attribute_points += 3  # 每升级获得3点属性
		print("★ LEVEL UP! New level: ", level, " | Gained 3 attribute points")
		level_up.emit(level, 3)
		exp_needed = level * 500

# 属性分配
func allocate_attribute(attr_name: String) -> bool:
	if attribute_points <= 0:
		print("No attribute points available!")
		return false

	match attr_name:
		"strength":
			strength += 1
			print("Strength increased to: ", strength)
		"agility":
			agility += 1
			print("Agility increased to: ", agility)
		"dexterity":
			dexterity += 1
			print("Dexterity increased to: ", dexterity)
		_:
			print("Invalid attribute name: ", attr_name)
			return false

	attribute_points -= 1
	attribute_changed.emit()
	return true

# 声望管理
func add_reputation(amount: int) -> void:
	var old_tier = get_reputation_tier()
	reputation += amount
	print("Reputation gained: +", amount, " | Total: ", reputation)

	var new_tier = get_reputation_tier()
	if new_tier != old_tier:
		print("★ Reputation tier up! New tier: ", new_tier)

	reputation_changed.emit(reputation)

func get_reputation_tier() -> String:
	if reputation >= 1000:
		return "传奇"
	elif reputation >= 600:
		return "大师级"
	elif reputation >= 300:
		return "专业级"
	elif reputation >= 100:
		return "熟练工"
	else:
		return "新手"

# 任务统计
func record_task_completion(rating: int) -> void:
	completed_tasks += 1
	total_rating += rating
	if rating >= 5:
		five_star_tasks += 1
	recent_ratings.append(rating)
	if recent_ratings.size() > MAX_RATING_HISTORY:
		recent_ratings.pop_front()
	print("Task completed! Rating: ", rating, "★ | Total tasks: ", completed_tasks)

func get_average_rating() -> float:
	if completed_tasks == 0:
		return 0.0
	return total_rating / completed_tasks

func get_last_rating() -> int:
	if recent_ratings.is_empty():
		return 0
	return recent_ratings[-1]

# 工具管理
func equip_tool(tool_type: String, tool_data: Dictionary) -> void:
	equipped_tools[tool_type] = tool_data
	# 记录为已拥有
	var found = false
	for t in owned_tools:
		if t.get("name", "") == tool_data.get("name", ""):
			found = true
			break
	if not found:
		owned_tools.append(tool_data.duplicate())
	print("Equipped tool: ", tool_data.name, " (", tool_type, ")")

func get_tool_efficiency(tool_type: String) -> float:
	if equipped_tools.has(tool_type):
		return equipped_tools[tool_type].get("efficiency", 1.0)
	return 1.0

func owns_tool(tool_name: String) -> bool:
	for t in owned_tools:
		if t.get("name", "") == tool_name:
			return true
	return false

# 保存/加载
func save_game() -> void:
	var save_data = {
		"player_name": player_name,
		"company_name": company_name,
		"gold": gold,
		"experience": experience,
		"level": level,
		"attribute_points": attribute_points,
		"strength": strength,
		"agility": agility,
		"dexterity": dexterity,
		"reputation": reputation,
		"equipped_tools": equipped_tools,
		"owned_tools": owned_tools,
		"completed_tasks": completed_tasks,
		"total_earnings": total_earnings,
		"five_star_tasks": five_star_tasks,
		"total_rating": total_rating,
		"recent_ratings": recent_ratings,
	}

	var file = FileAccess.open("user://save_data.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data, "\t"))
		file.close()
		print("Game saved successfully")
	else:
		print("Error saving game!")

func load_game() -> void:
	if not FileAccess.file_exists("user://save_data.json"):
		print("No save file found")
		return

	var file = FileAccess.open("user://save_data.json", FileAccess.READ)
	if not file:
		print("Error loading save file!")
		return

	var json_text = file.get_as_text()
	file.close()

	var json = JSON.new()
	var error = json.parse(json_text)
	if error != OK:
		print("Error parsing save file!")
		return

	var data = json.data
	if not data is Dictionary:
		print("Invalid save data!")
		return

	player_name = data.get("player_name", player_name)
	company_name = data.get("company_name", company_name)
	gold = int(data.get("gold", gold))
	experience = int(data.get("experience", experience))
	level = int(data.get("level", level))
	attribute_points = int(data.get("attribute_points", attribute_points))
	strength = int(data.get("strength", strength))
	agility = int(data.get("agility", agility))
	dexterity = int(data.get("dexterity", dexterity))
	reputation = int(data.get("reputation", reputation))

	if data.has("equipped_tools"):
		equipped_tools = data.equipped_tools
	if data.has("owned_tools"):
		owned_tools.clear()
		for t in data.owned_tools:
			owned_tools.append(t)

	completed_tasks = int(data.get("completed_tasks", completed_tasks))
	total_earnings = int(data.get("total_earnings", total_earnings))
	five_star_tasks = int(data.get("five_star_tasks", five_star_tasks))
	total_rating = float(data.get("total_rating", total_rating))

	if data.has("recent_ratings"):
		recent_ratings.clear()
		for r in data.recent_ratings:
			recent_ratings.append(int(r))

	# Emit signals to update UI
	gold_changed.emit(gold)
	attribute_changed.emit()
	reputation_changed.emit(reputation)

	print("Game loaded successfully")

extends Node

# 游戏状态枚举
enum GameState { CITY_MAP, WORKING, MENU, SHOP }
var current_state: GameState = GameState.CITY_MAP

# 场景路径
const CITY_MAP_SCENE = "res://scenes/city/city_map.tscn"
const WORK_SITE_SCENE = "res://scenes/work_sites/work_site.tscn"

func _ready() -> void:
	print("GameManager initialized")
	# 启动时自动加载存档
	_auto_load()

func _auto_load() -> void:
	PlayerData.load_game()
	# 加载任务状态
	if FileAccess.file_exists("user://save_tasks.json"):
		var file = FileAccess.open("user://save_tasks.json", FileAccess.READ)
		if file:
			var json = JSON.new()
			var err = json.parse(file.get_as_text())
			file.close()
			if err == OK and json.data is Dictionary:
				TaskManager.load_tasks(json.data)

func change_scene(scene_path: String) -> void:
	print("Changing scene to: ", scene_path)
	get_tree().change_scene_to_file(scene_path)

func start_work() -> void:
	if TaskManager.active_task.is_empty():
		print("错误：没有活动任务")
		return

	current_state = GameState.WORKING
	change_scene(WORK_SITE_SCENE)

func return_to_city() -> void:
	current_state = GameState.CITY_MAP
	change_scene(CITY_MAP_SCENE)
	# 返回城市时自动保存
	_auto_save()

func _auto_save() -> void:
	PlayerData.save_game()
	# 保存任务状态
	var task_data = TaskManager.save_tasks()
	var file = FileAccess.open("user://save_tasks.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(task_data, "\t"))
		file.close()
		print("Tasks saved")

func pause_game() -> void:
	get_tree().paused = true

func resume_game() -> void:
	get_tree().paused = false
